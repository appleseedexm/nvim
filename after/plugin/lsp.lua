local lsp = require("lsp-zero")
local mason = require("mason")
local masonlspconfig = require("mason-lspconfig")

lsp.on_attach(function(client, bufnr)
    local opts = { buffer = bufnr, remap = false }

    vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
    vim.keymap.set("n", "gD", function() vim.lsp.buf.declaration() end, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
    vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
    vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
    vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
    vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
    vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
    vim.keymap.set("v", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
    vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
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
