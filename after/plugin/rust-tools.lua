local rust_cmds = vim.api.nvim_create_augroup('rust_cmds', { clear = true })

local function rust_dap()
    local extension_path = require('mason-registry')
        .get_package('codelldb')
        :get_install_path() .. '/extension/'
    local codelldb_path = extension_path .. 'adapter/codelldb'
    local liblldb_path = extension_path .. 'lldb/lib/liblldb'
    local this_os = vim.loop.os_uname().sysname;

    -- The path in windows is different
    if this_os:find "Windows" then
        codelldb_path = extension_path .. "adapter\\codelldb.exe"
        liblldb_path = extension_path .. "lldb\\bin\\liblldb.dll"
    else
        -- The liblldb extension is .so for linux and .dylib for macOS
        liblldb_path = liblldb_path .. (this_os == "Linux" and ".so" or ".dylib")
    end

    return {
        adapter = require('rust-tools.dap').get_codelldb_adapter(
            codelldb_path, liblldb_path)
    }
end

local function on_attach(_, bufnr)
    local rt = require("rust-tools")

    -- Hover actions
    vim.keymap.set("n", "<C-space>", rt.hover_actions.hover_actions, { buffer = bufnr })
    -- Code action groups
    vim.keymap.set("n", "<leader>ca", rt.code_action_group.code_action_group, { buffer = bufnr })
    vim.keymap.set("n", "<leader>cru", rt.runnables.runnables, { buffer = bufnr })
end

local function setup()
    --setup_dap()

    local rt = require("rust-tools")
    rt.setup({
        server = {
            on_attach = on_attach,
        },
        dap = rust_dap()
    })
end

setup()
