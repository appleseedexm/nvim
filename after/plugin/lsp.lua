local lsp = require("lsp-zero")
local mason = require("mason")
local masonlspconfig = require("mason-lspconfig")

lsp.on_attach(function(client, bufnr)
    local opts = { buffer = bufnr, remap = false }

    vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
    vim.keymap.set("n", "gr", function() vim.lsp.buf.references() end, opts)
    vim.keymap.set("n", "gD", function() vim.lsp.buf.declaration() end, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
    vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
    vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
    vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
    vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
    vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
    vim.keymap.set("v", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
    vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
    vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, opts)
    vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
    vim.keymap.set("n", "<leader>f", vim.lsp.buf.format, opts)
end)

local function organize_imports()
    local params = {
        command = "_typescript.organizeImports",
        arguments = { vim.api.nvim_buf_get_name(0) },
        title = ""
    }
    vim.lsp.buf.execute_command(params)
end

local angularls_setup = function()
    require('lspconfig').angularls.setup({
        root_dir = require('lspconfig').util.root_pattern('angular.json', 'project.json'),
        server = {
            on_attach = function(client, bufnr)
                vim.keymap.set('n', 'co', '<cmd>OrganizeImports<cr>', { buffer = bufnr })
            end
        },
        commands = {
            OrganizeImports = {
                organize_imports,
                description = "Organize Imports"
            }
        }
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

mason.setup({})
masonlspconfig.setup({
    ensure_installed = {},
    handlers = {
        lsp.default_setup,
        jdtls = lsp.noop,
        rust_analyzer = lsp.noop,
        angularls = angularls_setup,
        lua_ls = lua_ls_setup,
        lemminx = lemminx_setup,
        golangci_lint_ls = golang_setup,
        kotlin_language_server = kotlin_setup,
    }
})

local cmp = require('cmp')
local cmp_format = lsp.cmp_format()
local cmp_select = { behavior = cmp.SelectBehavior.Select }

cmp.setup({
    formatting = cmp_format,
    mapping = cmp.mapping.preset.insert({
        ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
        ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
        ['<C-y>'] = cmp.mapping.confirm({ select = true }),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<Tab>'] = nil,
        ['<S-Tab>'] = nil,
    })
})

--cmp_mappings['<Tab>'] = nil
--cmp_mappings['<S-Tab>'] = nil

--lsp.setup_nvim_cmp({
--mapping = cmp_mappings
--})

lsp.set_preferences({
    suggest_lsp_servers = true,
})

lsp.set_sign_icons({
    error = 'E',
    warn = 'W',
    hint = 'H',
    info = 'I'
})

vim.diagnostic.config({
    virtual_text = true
})
