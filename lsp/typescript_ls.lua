return require('asx.lsp').mk_config({
    cmd = { 'typescript-language-server', '--stdio' },
    filetypes = { 'typescript', 'javascript' },
    root_dir = vim.fs.root(0, { '.git', 'package.json' }),
    on_attach = function(client, bufnr)
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
