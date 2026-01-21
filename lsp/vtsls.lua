return require('asx.lsp').mk_config({
    on_attach = function(client, bufnr)
        vim.keymap.set('n', '<leader>co', '<cmd>OrganizeImports<cr>', { buffer = bufnr })
        vim.api.nvim_create_user_command(
            "OrganizeImports",
            function()
                local command = {
                    command = "typescript.organizeImports",
                    arguments = { vim.api.nvim_buf_get_name(0) },
                }
                vim.lsp.buf.execute_command(command)
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
