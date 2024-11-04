return function(args, markers)

    local cmd = require('lspconfig').angularls.document_config.default_config.cmd
    return {
        cmd = cmd,
        on_new_config = function(new_config, new_root_dir)
            new_config.cmd = cmd
        end,
        name = "ngserver",
        root_dir = require('lspconfig').util.root_pattern(markers),
        on_attach = function(client, bufnr)
            vim.api.nvim_create_user_command(
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
                end,
                {}
            )
        end,
    }
end
