local lsp = require("lsp-zero")
local mason = require("mason")
local masonlspconfig = require("mason-lspconfig")

local angularls_setup = function()
    require('lspconfig').angularls.setup({
        root_dir = require('lspconfig').util.root_pattern('angular.json', 'project.json'),
        server = {
            on_attach = function(client, bufnr)
                vim.keymap.set('n', 'co', '<cmd>OrganizeImports<cr>', { buffer = bufnr })
                vim.api.nvim_create_user_command(
                    "RelativeCodeFormat",
                    function()
                        vim.cmd("EslintFixAll")
                        vim.cmd("FormatCode")
                    end,
                    {}
                )
            end
        },
        commands = {
            OrganizeImports = {
                function()
                    local params = {
                        command = "_typescript.organizeImports",
                        arguments = { vim.api.nvim_buf_get_name(0) },
                        title = ""
                    }
                    vim.lsp.buf.execute_command(params)
                end,
                description = "Organize Imports"
            }
        },
    })
end

local lua_ls_setup = function()
    require('lspconfig').lua_ls.setup(
        lsp.nvim_lua_ls({
            single_file_support = true,
        })
    )
end

local lemminx_setup = function()
    require('lspconfig').lemminx.setup({
        settings = {
            xml = {
                server = {
                    workDir = "~/.cache/lemminx",
                }
            }
        }
    })
end

local golang_setup = function()
    local lspconfig = require 'lspconfig'
    local configs = require 'lspconfig/configs'
    local dap = require 'dap'

    if not configs.golangcilsp then
        configs.golangcilsp = {
            default_config = {
                cmd = { 'golangci-lint-langserver' },
                root_dir = lspconfig.util.root_pattern('.git', 'go.mod'),
                init_options = {
                    command = { "golangci-lint", "run", "--enable-all", "--disable", "lll", "--out-format", "json", "--issues-exit-code=1" },
                }
            },
        }
    end
    lspconfig.golangci_lint_ls.setup {
        filetypes = { 'go', 'gomod' },
    }

    -- gopls
    lspconfig.gopls.setup {
        cmd = { "gopls" },
        filetypes = { "go", "gomod", "gowork", "gotmpl" },
        root_dir = lspconfig.util.root_pattern("go.work", "go.mod", ".git"),
        settings = {
            gopls = {
                completeUnimported = true,
                usePlaceholders = true,
                analyses = {
                    unusedparams = true,
                },
            },
        },
    }

    -- DAP
    dap.adapters.delve = {
        type = 'server',
        port = '${port}',
        executable = {
            command = 'dlv',
            args = { 'dap', '-l', '127.0.0.1:${port}' },
        }
    }

    -- https://github.com/go-delve/delve/blob/master/Documentation/usage/dlv_dap.md
    dap.configurations.go = {
        {
            type = "delve",
            name = "Debug",
            request = "launch",
            program = "${file}"
        },
        {
            type = "delve",
            name = "Debug test", -- configuration for debugging test files
            request = "launch",
            mode = "test",
            program = "${file}"
        },
        -- works with go.mod packages and sub packages
        {
            type = "delve",
            name = "Debug test (go.mod)",
            request = "launch",
            mode = "test",
            program = "./${relativeFileDirname}"
        }
    }
end

local kotlin_setup = function()
    local lspconfig = require('lspconfig')
    lspconfig.kotlin_language_server.setup({
        cmd = { 'kotlin-language-server' },
        root_dir = lspconfig.util.root_pattern('gradlew', 'pom.xml', '.git', 'settings.gradle.kts'),
        on_attach = function(client, bufnr)
            lspconfig.on_attach(client, bufnr)
            lspconfig.setup_buffer_keymaps(bufnr)
        end
    })
end

local css_setup = function()
    local lspconfig = require('lspconfig')
    lspconfig.cssls.setup({
        capabilities = lsp.capabilities,
        cmd = { 'vscode-css-language-server', '--stdio' },
        filetypes = { 'css', 'scss', 'less', 'sass' },
        root_dir = lspconfig.util.root_pattern('package.json', 'tsconfig.json', '.git'),
        init_options = {
            provideFormatter = true,
            provideHover = true,
            provideCompletionItem = true,
            provideCompletionItemResolve = true,
            provideDocumentFormattingEdits = true,
            provideDocumentRangeFormattingEdits = true,
            provideRenameEdits = true,
            provideSignatureHelp = true,
        },
        settings = {
            css = {
                format = {
                    enabled = true,
                    tabSize = 4,
                    newlineBetweenRules = true,
                    spaceAroundSelectorSeparator = true,
                    spaceAroundComma = true,
                    trimTrailingWhitespace = true,
                    insertBraces = true,
                    alwaysUseSingleQuotes = false,
                    quoteProps = 'as-needed',
                    cssLiteral = 'preserve',
                },
                validate = true,
                lint = {
                    compatibleVendorPrefixes = 'ignore',
                    vendorPrefix = 'warning',
                    duplicateProperties = 'warning',
                    emptyRules = 'warning',
                    importStatement = 'warning',
                    boxModel = 'warning',
                    universalSelector = 'warning',
                    zeroUnits = 'warning',
                    fontFaceProperties = 'warning',
                    hexColorLength = 'warning',
                    argumentsInColorFunction = 'warning',
                    unknownProperties = 'warning',
                    ieHack = 'warning',
                    unknownVendorSpecificProperties = 'warning',
                    propertyIgnoredDueToDisplay = 'warning',
                    important = 'warning',
                    float = 'warning',
                    idSelector = 'warning',
                },
            },
        }
    })
end

local html_setup = function()
    local lspconfig = require('lspconfig')
    lspconfig.html.setup({
        on_attach = function(client, bufnr)
            vim.api.nvim_create_user_command(
                "RelativeCodeFormat",
                function()
                    vim.cmd("FormatCode")
                end,
                {}
            )
        end,
        capabilities = lsp.capabilities,
        cmd = { 'vscode-html-language-server', '--stdio' },
        filetypes = { 'html', 'htmldjango', 'htmljinja', 'svelte', 'vue', 'windi' },
        root_dir = lspconfig.util.root_pattern('package.json', 'tsconfig.json', '.git'),
        init_options = {
            provideFormatter = true,
            provideHover = true,
            provideCompletionItem = true,
            provideCompletionItemResolve = true,
            provideDocumentFormattingEdits = true,
            provideDocumentRangeFormattingEdits = true,
            provideRenameEdits = true,
            provideSignatureHelp = true,
            emmetCompletions = true,
        },
        settings = {
            html = {
                format = {
                    enabled = false,
                },
                validate = {
                    scripts = true,
                    styles = true,
                },
                suggest = {
                    html5 = true,
                }
            }
        },
    })
end

local function pylsp_setup()
    local pylsp = require("lspconfig").pylsp
    pylsp.setup({
        settings = {
            pylsp = {
                plugins = {
                    pycodestyle = {
                        enabled = true,
                    },
                    pyflakes = {
                        enabled = true,
                    },
                    rope_completion = {
                        enabled = true,
                    },
                },
            }
        },
        setup = {
            function(client)
                client.server_capabilities.documentFormattingProvider = false
                client.server_capabilities.documentRangeFormattingProvider = false
            end
        }
    })
end

mason.setup({})
masonlspconfig.setup({
    ensure_installed = {},
    handlers = {
        lsp.default_setup,
        jdtls = lsp.noop,
        rust_analyzer = lsp.noop,
        angularls = lsp.noop,
        lua_ls = lsp.noop,
        ts_ls = lsp.noop,
        lemminx = lemminx_setup,
        golangci_lint_ls = golang_setup,
        kotlin_language_server = lsp.noop,
        cssls = lsp.noop,
        jsonls = lsp.noop,
        html = lsp.noop,
        pylsp = lsp.noop,
    }
})
