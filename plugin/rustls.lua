-- this just configures all rust related plugins based on lsp zero
local rust_cmds = vim.api.nvim_create_augroup('rust_cmds', { clear = true })

local function setup_dap()
    local dap = require('dap')

    local codelldb_path = require('mason-registry')
    .get_package('codelldb')
    :get_install_path()

    dap.adapters.codelldb = {
        type = 'server',
        port = "${port}",
        executable = {
            command = codelldb_path .. '/codelldb',
            args = { "--port", "${port}" },
        }
    }

    dap.configurations.rust = {
        {
            name = "Rust debug",
            type = "codelldb",
            request = "launch",
            program = function()
                return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/target/debug/', 'file')
            end,
            cwd = '${workspaceFolder}',
            stopOnEntry = true,
            showDisassembly = "never",
        },
    }
end

local function on_attach(_, bufnr)
    local rt  = require("rust-tools")

    -- Hover actions
    --vim.keymap.set("n", "<C-space>", rt.hover_actions.hover_actions, { buffer = bufnr })
    -- Code action groups
    vim.keymap.set("n", "<Leader>ca", rt.code_action_group.code_action_group, { buffer = bufnr })

end

local function setup(event)
    setup_dap()

    local lspzero = require("lsp-zero")
    local rt = require("rust-tools")
    local rust_lsp = lspzero.build_options('rust_analyzer', {})
    rust_lsp.on_attach = on_attach
    rt.setup({
        server = rust_lsp,
    })
end

vim.api.nvim_create_autocmd('FileType', {
    group = rust_cmds,
    pattern = { 'rust' },
    desc = 'Setup rustls',
    callback = setup,
})
