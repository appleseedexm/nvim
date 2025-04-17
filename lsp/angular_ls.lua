local cmd = { 'ngserver' }
local markers = { 'project.json', '.git' }

return require('asx.lsp').mk_config({
    cmd = cmd,
    filetypes = { "typescript", "html", "typescriptreact", "typescript.tsx", "htmlangular" },
    on_new_config = function(new_config, new_root_dir)
        new_config.cmd = cmd
    end,
    root_dir = vim.fs.root(0, markers),
    on_attach = function(client, bufnr)
        -- all of this should go into the TS config instead
        vim.api.nvim_buf_create_user_command(
            bufnr,
            "RelativeCodeFormat",
            function()
                vim.cmd("EslintFixAll")
                vim.cmd("FormatCode")
            end,
            {}
        )

        vim.keymap.set('n', '<leader>co', '<cmd>OrganizeImports<cr>', { buffer = bufnr })
        vim.api.nvim_create_user_command(
            "OrganizeImports",
            function()
                local params = {
                    command = "_typescript.organizeImports",
                    arguments = { vim.api.nvim_buf_get_name(0) },
                    title = ""
                }
                vim.lsp.buf.execute_command(params)
                vim.lsp.buf.code_action({
                    apply = true,
                    context = {
                        only = { "source.addMissingImports.ts" },
                    }
                })
            end,
            {}
        )
    end,
})
