print("LOADING JAVA PLUGIN")
local api = vim.api
local jdtls_install = require('mason-registry')
    .get_package('jdtls')
    :get_install_path()


local dap = require("dap")
---@type ExecutableAdapter
--dap.adapters.hprof = {
--type = "executable",
--command = os.getenv("GRAALVM_HOME") .. "/bin/java",
--args = {
---- "-agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=5005",
--"-Dpolyglot.engine.WarnInterpreterOnly=false",
--"-jar",
--vim.fn.expand("~/dev/mfussenegger/hprofdap/target/hprofdap-0.1.0-jar-with-dependencies.jar"),
--}
--}
--dap.configurations.java = {
--{
--name = "hprof (pick path)",
--request = "launch",
--type = "hprof",
--filepath = function()
--return require("dap.utils").pick_file({
--executables = false,
--filter = "%.hprof$"
--})
--end,
--},
--{
--name = "hprof (prompt path)",
--request = "launch",
--type = "hprof",
--filepath = function()
--local path = vim.fn.input("hprof path: ", "", "file")
--return path and vim.fn.fnamemodify(path, ":p") or dap.ABORT
--end,
--},
--}



local root_markers = { 'gradlew', 'mvnw', '.git' }
local root_dir = vim.fs.root(0, root_markers) or vim.fs.root(0, { "pom.xml" })
if not root_dir then
    print("No root dir found")
    return
end
print("ROOT DIR FOUND")
local home = os.getenv('HOME')
print("ROOT DIR FOUND")
local workspace_folder = home .. "/.local/share/eclipse/" .. vim.fn.fnamemodify(root_dir, ":p:h:t")
print("ROOT DIR FOUND")
local jdtls = require('jdtls')
--jdtls.jol_path = os.getenv('HOME') .. '/apps/jol.jar'
local config = require('asx.lsp').mk_config({
    root_dir = root_dir,
    settings = {
        java = {
            autobuild = { enabled = false },
            maxConcurrentBuilds = 1,
            signatureHelp = { enabled = true },
            contentProvider = { preferred = 'fernflower' },
            saveActions = {
                organizeImports = true,
            },
            completion = {
                favoriteStaticMembers = {
                    "io.crate.testing.Asserts.assertThat",
                    "org.assertj.core.api.Assertions.assertThat",
                    "org.assertj.core.api.Assertions.assertThatThrownBy",
                    "org.assertj.core.api.Assertions.assertThatExceptionOfType",
                    "org.assertj.core.api.Assertions.catchThrowable",
                    "org.hamcrest.MatcherAssert.assertThat",
                    "org.hamcrest.Matchers.*",
                    "org.hamcrest.CoreMatchers.*",
                    "org.junit.jupiter.api.Assertions.*",
                    "java.util.Objects.requireNonNull",
                    "java.util.Objects.requireNonNullElse",
                    "org.mockito.Mockito.*",
                },
                filteredTypes = {
                    "com.sun.*",
                    "io.micrometer.shaded.*",
                    "java.awt.*",
                    "jdk.*",
                    "sun.*",
                },
            },
            sources = {
                organizeImports = {
                    starThreshold = 9999,
                    staticStarThreshold = 9999,
                },
            },
            codeGeneration = {
                toString = {
                    template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}"
                },
                hashCodeEquals = {
                    useJava7Objects = true,
                },
                useBlocks = true,
                addFinalForNewDeclaration = "fields",
            },
            configuration = {
                runtimes = {
                    {
                        name = 'JavaSE-17',
                        path = vim.fn.expand('~/.sdkman/candidates/java/17.0.11-ms'),
                    },
                }
            }
        }
    },
    cmd = {
        "java",
        "-javaagent:" .. jdtls_install .. '/lombok.jar',
        --'-agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=1044',
        '-Declipse.application=org.eclipse.jdt.ls.core.id1',
        '-Dosgi.bundles.defaultStartLevel=4',
        '-Declipse.product=org.eclipse.jdt.ls.core.product',
        '-Dlog.protocol=true',
        '-Dlog.level=ALL',
        '-Xmx4g',
        '--add-modules=ALL-SYSTEM',
        '--add-opens', 'java.base/java.util=ALL-UNNAMED',
        '--add-opens', 'java.base/java.lang=ALL-UNNAMED',
        '-jar', vim.fn.glob(jdtls_install .. '/plugins/org.eclipse.equinox.launcher_*.jar'),
        '-configuration', jdtls_install .. '/config_linux_arm',
        '-data', workspace_folder,
    }
})


local function test_with_profile(test_fn)
    return function()
        local choices = {
            'cpu,alloc=2m,lock=10ms',
            'cpu',
            'alloc',
            'wall',
            'context-switches',
            'cycles',
            'instructions',
            'cache-misses',
        }
        local select_opts = {
            format_item = tostring
        }
        vim.ui.select(choices, select_opts, function(choice)
            if not choice then
                return
            end
            local async_profiler_so = home .. "/apps/async-profiler/lib/libasyncProfiler.so"
            local event = 'event=' .. choice
            local vmArgs = "-ea -agentpath:" .. async_profiler_so .. "=start,"
            vmArgs = vmArgs .. event .. ",file=/tmp/profile.jfr"
            test_fn({
                config_overrides = {
                    vmArgs = vmArgs,
                    noDebug = true,
                },
                after_test = function()
                    vim.fn.system("jfr2flame /tmp/profile.jfr /tmp/profile.html")
                    vim.fn.system("firefox /tmp/profile.html")
                end
            })
        end)
    end
end

print("now on attach")

config.on_attach = function(client, bufnr)
    local function with_compile(fn)
        return function()
            if vim.bo.modified then
                vim.cmd("w")
            end
            client.request_sync("java/buildWorkspace", false, 5000, bufnr)
            fn()
        end
    end

    api.nvim_buf_create_user_command(bufnr, "A", function()
        require("jdtls.tests").goto_subjects()
    end, {})

    local triggers = vim.tbl_get(client.server_capabilities, "completionProvider", "triggerCharacters")
    if triggers then
        for _, char in ipairs({ "a", "e", "i", "o", "u" }) do
            if not vim.tbl_contains(triggers, char) then
                table.insert(triggers, char)
            end
        end
    end
    if vim.lsp.completion then
        vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = true })
    else
        --require('lsp_compl').attach(client, bufnr, {
        --server_side_fuzzy_completion = true,
        --})
    end

    local opts = { silent = true, buffer = bufnr }
    local set = vim.keymap.set
    set("n", "<F5>", with_compile(function()
        dap.continue()
    end), opts)
    set('n', "<A-o>", jdtls.organize_imports, opts)
    set('n', "<leader>df", with_compile(function()
        jdtls.test_class({
            config_overrides = {
                vmArgs = "-ea -XX:+TieredCompilation -XX:TieredStopAtLevel=1",
            }
        })
    end), opts)
    set('n', "<leader>dl", with_compile(require("dap").run_last), opts)
    set('n', "<leader>dF", with_compile(test_with_profile(jdtls.test_class)), opts)
    set('n', "<leader>dn", with_compile(function()
        jdtls.test_nearest_method({
            config_overrides = {
                stepFilters = {
                    skipClasses = { "$JDK", "junit.*" },
                    skipSynthetics = true
                },
                vmArgs = "-ea -XX:+TieredCompilation -XX:TieredStopAtLevel=1",
            }
        })
    end), opts)
    set('n', "<leader>dN", with_compile(test_with_profile(jdtls.test_nearest_method)), opts)

    vim.keymap.set('n', "crv", jdtls.extract_variable_all, opts)
    vim.keymap.set('v', "crv", [[<ESC><CMD>lua require('jdtls').extract_variable_all(true)<CR>]], opts)
    vim.keymap.set('v', 'crm', [[<ESC><CMD>lua require('jdtls').extract_method(true)<CR>]], opts)
    vim.keymap.set('n', "crc", jdtls.extract_constant, opts)
    vim.keymap.set("n", "<leader>ds", function()
        if dap.session() then
            local widgets = require("dap.ui.widgets")
            widgets.centered_float(widgets.scopes)
        else
            client.request_sync("java/buildWorkspace", false, 5000, bufnr)
            require("jdtls.dap").pick_test()
        end
    end, opts)
end


local java_test_path = require('mason-registry')
    .get_package('java-test')
    :get_install_path() .. '/extension/server'


local java_debug_path = require('mason-registry')
    .get_package('java-debug-adapter')
    :get_install_path() .. '/extension/server'


local jar_patterns = {
    java_debug_path .. '/com.microsoft.java.debug.plugin-*.jar',
    --'/dev/dgileadi/vscode-java-decompiler/server/*.jar',
    java_test_path .. '/*.jar',
    --'/dev/testforstephen/vscode-pde/server/*.jar'
}
-- npm install broke for me: https://github.com/npm/cli/issues/2508
-- So gather the required jars manually; this is based on the gulpfile.js in the vscode-java-test repo
local plugin_path =
    java_test_path .. '/'
local bundle_list = vim.tbl_map(
    function(x) return require('jdtls.path').join(plugin_path, x) end,
    {
        'junit-jupiter-*.jar',
        'junit-platform-*.jar',
        'junit-vintage-engine_*.jar',
        'org.opentest4j*.jar',
        'org.apiguardian.api_*.jar',
        'org.eclipse.jdt.junit4.runtime_*.jar',
        'org.eclipse.jdt.junit5.runtime_*.jar',
        'org.opentest4j_*.jar',
        'org.jacoco.*.jar',
        'org.objectweb.asm*.jar'
    }
)
vim.list_extend(jar_patterns, bundle_list)
local bundles = {}
for _, jar_pattern in ipairs(jar_patterns) do
    for _, bundle in ipairs(vim.split(vim.fn.glob(home .. jar_pattern), '\n')) do
        if not vim.endswith(bundle, 'com.microsoft.java.test.runner-jar-with-dependencies.jar')
            and not vim.endswith(bundle, 'com.microsoft.java.test.runner.jar') then
            table.insert(bundles, bundle)
        end
    end
end
local extendedClientCapabilities = jdtls.extendedClientCapabilities;
extendedClientCapabilities.onCompletionItemSelectedCommand = "editor.action.triggerParameterHints"
config.init_options = {
    bundles = bundles,
    extendedClientCapabilities = extendedClientCapabilities,
}
-- mute; having progress reports is enough
print("STARTING JAVA SERVER")
--config.handlers['language/status'] = function() end
jdtls.start_or_attach(config)
