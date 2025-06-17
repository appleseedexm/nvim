local dap = require('dap')

local function zig_dap()
    local extension_path =
        vim.fn.expand("$MASON/packages/codelldb/extension/")
    local codelldb_path = extension_path .. 'adapter/codelldb'
    local liblldb_path = extension_path .. 'lldb/lib/liblldb'
    local this_os = vim.loop.os_uname().sysname;

    liblldb_path = liblldb_path .. (this_os == "Linux" and ".so" or ".dylib")
    dap.adapters.codelldb = {
        type = "server",
        port = "${port}",
        executable = {
            command = "codelldb",
            args = { "--port", "${port}" }
        }
    }
    dap.configurations.zig = {
        {
            name = 'Launch',
            type = 'codelldb',
            request = 'launch',
            program = '${workspaceFolder}/zig-out/bin/${workspaceFolderBasename}',
            cwd = '${workspaceFolder}',
            stopOnEntry = false,
            args = {},
        },
    }
end

return require('asx.lsp').mk_config({
    cmd = { "zls" },
    filetypes = { "zig", "zir" },
    settings = {
        semantic_tokens = "partial",
    },
    before_init  = function()
        zig_dap()
    end,
})
