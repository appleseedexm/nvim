local api = vim.api
local jdtls_install = require('mason-registry')
    .get_package('jdtls')
    :get_install_path()


local dap = require("dap")
---@type ExecutableAdapter
dap.adapters.hprof = {
    type = "executable",
    --command = os.getenv("GRAALVM_HOME") .. "/bin/java",
    command = "java",
    args = {
        -- "-agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=5005",
        "-Dpolyglot.engine.WarnInterpreterOnly=false",
        --"-jar",
        --vim.fn.expand("~/dev/mfussenegger/hprofdap/target/hprofdap-0.1.0-jar-with-dependencies.jar"),
    }
}
dap.configurations.java = {
    {
        type = 'java',
        request = 'attach',
        name = "Debug (Attach) - Remote",
        hostName = "127.0.0.1",
        port = 5005,
    },
    {
        name = "hprof (pick path)",
        request = "launch",
        type = "hprof",
        filepath = function()
            return require("dap.utils").pick_file({
                executables = false,
                filter = "%.hprof$"
            })
        end,
    },
    {
        name = "hprof (prompt path)",
        request = "launch",
        type = "hprof",
        filepath = function()
            local path = vim.fn.input("hprof path: ", "", "file")
            return path and vim.fn.fnamemodify(path, ":p") or dap.ABORT
        end,
    },
}



local root_markers = { 'gradlew', 'mvnw', '.git' }
local root_dir = vim.fs.root(0, root_markers) or vim.fs.root(0, { "pom.xml" })
if not root_dir then
    return
end
local home = os.getenv('HOME')
local workspace_folder = home .. "/.local/share/eclipse/" .. vim.fn.fnamemodify(root_dir, ":p:h:t")
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
            completion = {
                favoriteStaticMembers = {
                    'org.hamcrest.MatcherAssert.assertThat',
                    'org.hamcrest.Matchers.*',
                    'org.hamcrest.CoreMatchers.*',
                    'java.util.Objects.requireNonNull',
                    'java.util.Objects.requireNonNullElse',
                    'org.mockito.Mockito.*',
                    'org.mockito.ArgumentMatchers.*',
                    'org.mockito.Answers.*',
                    'org.junit.Assert.*',
                    'org.junit.Assume.*',
                    'org.junit.jupiter.api.Assertions.*',
                    'org.junit.jupiter.api.Assumptions.*',
                    'org.junit.jupiter.api.DynamicContainer.*',
                    'org.junit.jupiter.api.DynamicTest.*',
                    'org.assertj.core.api.Assertions.*',
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
    api.nvim_create_user_command(
        "RelativeCodeFormat",
        function()
            vim.cmd("FormatCode")
        end,
        {}
    )

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


    -- debug / test
    set("n", "<leader>dsc", with_compile(function()
        dap.continue()
    end), opts)
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
    set('n', '<leader>dj', require('jdtls.tests').goto_subjects, opts)
    set('n', '<leader>dg', require('jdtls.tests').generate, opts)
    set("n", "<leader>dss", function()
        if dap.session() then
            local widgets = require("dap.ui.widgets")
            widgets.centered_float(widgets.scopes)
        else
            client.request_sync("java/buildWorkspace", false, 5000, bufnr)
            require("jdtls.dap").pick_test()
        end
    end, opts)

    -- basic keymaps
    set('n', "<leader>co", jdtls.organize_imports, opts)
    set('n', "crv", jdtls.extract_variable_all, opts)
    set('v', "crv", [[<ESC><CMD>lua require('jdtls').extract_variable_all(true)<CR>]], opts)
    set('v', 'crm', [[<ESC><CMD>lua require('jdtls').extract_method(true)<CR>]], opts)
    set('v', 'crc', [[<ESC><CMD>lua require('jdtls').extract_constant(true)<CR>]], opts)
    set('n', "crc", jdtls.extract_constant, opts)
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

local bundles = {}
for _, jar_pattern in ipairs(jar_patterns) do
    for _, bundle in ipairs(vim.split(vim.fn.glob(jar_pattern), '\n')) do
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
--config.handlers['language/status'] = function() end
jdtls.start_or_attach(config)
