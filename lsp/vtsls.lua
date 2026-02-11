return require('asx.lsp').mk_config({
    on_attach = function(client, bufnr)
        -- local command = "_typescript.organizeImports"
        -- local filename = vim.api.nvim_buf_get_name(bufnr)
        -- client:request(command, { filename }, nil, bufnr)

        vim.keymap.set('n', '<leader>coo', '<cmd>OrganizeImports<cr>', { buffer = bufnr })
        vim.api.nvim_create_user_command(
            "OrganizeImports",
            function()
                vim.lsp.buf.code_action({
                    apply = true,
                    context = {
                        only = { "source.organizeImports" },
                    }
                })
            end,
            {}
        )

        vim.keymap.set('n', '<leader>coi', '<cmd>OrganizeMissingImports<cr>', { buffer = bufnr })
        vim.api.nvim_create_user_command(
            "OrganizeMissingImports",
            function()
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
