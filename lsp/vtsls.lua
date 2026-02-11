return require('asx.lsp').mk_config({
    on_attach = function(client, bufnr)
        vim.keymap.set('n', '<leader>co', '<cmd>OrganizeImports<cr>', { buffer = bufnr })
        vim.api.nvim_create_user_command(
            "OrganizeImports",
            function()
                -- local command = "_typescript.organizeImports"
                -- local filename = vim.api.nvim_buf_get_name(bufnr)
                -- client:request(command, { filename }, nil, bufnr)

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
