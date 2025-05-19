local local_jdtls = false
local local_java_test = false

local home = os.getenv('HOME')
local jdk17 = vim.fn.expand('~/.sdkman/candidates/java/17.0.14-tem')
local jdk21 = vim.fn.expand('~/.sdkman/candidates/java/21.0.2-open')
local jdk23 = vim.fn.expand('~/.sdkman/candidates/java/23.0.1-open')
local jdk = jdk21

local api = vim.api
local jdtls_install = local_jdtls and home .. "/code/eclipse.jdt.ls/org.eclipse.jdt.ls.product/target/repository" or
    vim.fn.expand("$MASON/packages/jdtls")

local lombok_ver = "lombok-1.18.38.jar"
local lombok = local_jdtls and home .. "/code/libs/java/" .. lombok_ver or jdtls_install .. "/lombok.jar"
local sys_arch = vim.loop.os_uname().machine == "aarch64" and "linux_arm" or "linux"

-- dap
local dap = require("dap")
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

-- jdtls
local root_markers = { 'gradlew', 'mvnw', '.git' }
local root_dir = vim.fs.root(0, root_markers) or vim.fs.root(0, { "pom.xml" })
if not root_dir then
    print("JDTLS: Could not find rootdir")
    return
end
local workspace_folder = home .. "/.local/share/jdtls/" .. vim.fn.fnamemodify(root_dir, ":p:h:t")
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
                    useJava7Objects = false,
                    useInstanceOf = true,
                },
                useBlocks = true,
                addFinalForNewDeclaration = "fields",
            },
            configuration = {
                runtimes = {
                    {
                        name = 'JavaSE-17',
                        path = jdk17,
                        default = true,
                    },
                    {
                        name = 'JavaSE-21',
                        path = jdk21,
                    },
                    {
                        name = 'JavaSE-23',
                        path = jdk23,
                    },
                }
            },
            symbols = {
                includeSourceMethodDeclarations = true
            },
        }
    },
    cmd = {
        jdk .. "/bin/java",
        "-javaagent:" .. lombok,
        --'-agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=1044',
        '-Declipse.application=org.eclipse.jdt.ls.core.id1',
        '-Dosgi.bundles.defaultStartLevel=4',
        '-Declipse.product=org.eclipse.jdt.ls.core.product',
        '-Dlog.protocol=true',
        '-Dlog.level=ALL',
        '-Xmx4g',
        '-XX:+AlwaysPreTouch',
        '--add-modules=ALL-SYSTEM',
        '--add-opens', 'java.base/java.util=ALL-UNNAMED',
        '--add-opens', 'java.base/java.lang=ALL-UNNAMED',
    }
})

if sys_arch == 'linux' then
    vim.list_extend(config.cmd, {
        '-XX:+UseTransparentHugePages',
    })
end

local launcher = vim.fn.glob(jdtls_install .. '/plugins/org.eclipse.equinox.launcher_*.jar')
if vim.uv.fs_stat(launcher) then
    vim.list_extend(config.cmd, {
        "-jar", launcher,
        "-configuration", jdtls_install .. "/config_" .. sys_arch,
        "-data", workspace_folder
    })
else
    print("JDTLS no equinox launcher found")
    return
    --vim.list_extend(config.cmd, {
    --"-Dosgi.checkConfiguration=true",
    --"-Dosgi.sharedConfiguration.area=/usr/share/java/jdtls/config_linux/",
    --"-Dosgi.sharedConfiguration.area.readOnly=true",
    --"-Dosgi.configuration.cascaded=true",
    --"-jar", vim.fn.glob("/usr/share/java/jdtls/plugins/org.eclipse.equinox.launcher_*.jar"),
    --"-data", workspace_folder,
    --})
end

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
            vmArgs = vmArgs .. event .. ",collapsed,file=/tmp/jdtls_traces.txt"
            test_fn({
                config_overrides = {
                    vmArgs = vmArgs,
                    noDebug = true,
                },
                after_test = function()
                    vim.cmd.tabnew()
                    vim.fn.jobstart({ "flamelens", "/tmp/jdtls_traces.txt" }, { term = true })
                    vim.cmd.startinsert()
                end
            })
        end)
    end
end

config.on_attach = function(client, bufnr)
    local function compile()
        if vim.bo.modified then
            vim.cmd("w")
        end
        client.request_sync("java/buildWorkspace", false, 5000, bufnr)
    end

    local function with_compile(fn)
        return function()
            compile()
            fn()
        end
    end

    api.nvim_buf_create_user_command(bufnr, "A", function()
        require("jdtls.tests").goto_subjects()
    end, {})


    local opts = { silent = true, buffer = bufnr }
    local set = vim.keymap.set
    set("n", "<F5>", function()
        if dap.session() == nil then
            compile()
            dap.continue()
        else
            dap.continue()
        end
    end, opts)

    api.nvim_buf_create_user_command(
        bufnr,
        "RelativeCodeFormat",
        function()
            vim.cmd("FormatCode")
            vim.cmd("w")
        end,
        {}
    )


    -- debug / test
    local conf_overrides = {
        stepFilters = {
            skipClasses = { "$JDK", "junit.*" },
            skipSynthetics = true
        },
        vmArgs = table.concat({
            "-ea",
            "-XX:+TieredCompilation",
            "-XX:TieredStopAtLevel=1",
            "--enable-native-access=ALL-UNNAMED",
        }, " "),
    }

    set("n", "<leader>dsc", with_compile(function()
        dap.continue()
    end), opts)
    set('n', "<leader>df", with_compile(function()
        jdtls.test_class({ config_overrides = conf_overrides })
    end), opts)
    set('n', "<leader>dl", with_compile(require("dap").run_last), opts)
    set('n', "<leader>dF", with_compile(test_with_profile(jdtls.test_class)), opts)
    set('n', "<leader>dn", with_compile(function()
        jdtls.test_nearest_method({ config_overrides = conf_overrides })
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

---@return table
local function bundle_jar_patterns()
    local java_debug_path =
        vim.fn.expand("$MASON/packages/java-debug-adapter/extension/server")

    local java_decomp_path =
        vim.fn.expand("$MASON/packages/vscode-java-decompiler/server")

    local jar_patterns = {
        java_debug_path .. '/com.microsoft.java.debug.plugin-*.jar',
        java_decomp_path .. '/*.jar',
    }


    -- Add java-test
    if local_java_test then
        vim.list_extend(jar_patterns,
            {
                home .. '/code/microsoft/vscode-java-test/java-extension/com.microsoft.java.test.plugin/target/*.jar',
                home .. '/code/microsoft/vscode-java-test/java-extension/com.microsoft.java.test.runner/target/*.jar',
                home .. '/code/microsoft/vscode-java-test/java-extension/com.microsoft.java.test.runner/lib/*.jar',
                --home .. '/code/microsoft/vscode-java-test/server/*.jar',
            })
        local plugin_path =
            home ..
            '/code/microsoft/vscode-java-test/java-extension/com.microsoft.java.test.plugin.site/target/repository/plugins/'
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
    else
        local java_test_path =
            vim.fn.expand("$MASON/packages/java-test/extension/server")
        vim.list_extend(jar_patterns, {
            java_test_path .. '/*.jar',
        })
    end
    return jar_patterns
end

local jar_patterns = bundle_jar_patterns()
local bundles = {}
for _, jar_pattern in ipairs(jar_patterns) do
    for _, bundle in ipairs(vim.split(vim.fn.glob(jar_pattern), '\n')) do
        if true
            and not vim.endswith(bundle, 'com.microsoft.java.test.runner-jar-with-dependencies.jar')
            and not vim.endswith(bundle, 'com.microsoft.java.test.runner.jar')
            and bundle ~= ""
        then
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
config.capabilities =
    vim.tbl_deep_extend(
        "force",
        config.capabilities,
        {
            workspace = {
                didChangeWatchedFiles = {
                    dynamicRegistration = false
                }
            },
        }
    )
-- mute; having progress reports is enough
--config.handlers['language/status'] = function() end
jdtls.start_or_attach(config)
