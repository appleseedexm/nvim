return function(args, markers)
    --local project_root_dir = vim.fs.root(args.file, markers)
    --local ng_root_dir = require('lspconfig').angularls.root_dir()
    --local cmd = 'ngserver --stdio --tsProbeLocations ' ..
    --ng_root_dir .. '/node_modules,' .. project_root_dir .. '/node_modules ' ..
    --'--ngProbeLocations ' ..
    --ng_root_dir .. '/node_modules/@angular/language-server/node_modules,' .. project_root_dir .. '/node_modules'
    local cmd = require('lspconfig').angularls.document_config.default_config.cmd
    return {
        cmd = cmd,
        name = "ngserver",
        root_dir = require('lspconfig').util.root_pattern(markers),
        server = {
            on_attach = function(client, bufnr)
                vim.keymap.set('n', 'co', '<cmd>OrganizeImports<cr>', { buffer = bufnr })
                vim.api.nvim_create_user_command(
                    "RelativeCodeFormat",
                    function()
                        vim.cmd("EslintFixAll")
                        vim.cmd("FormatCode")
                    end,
                    {}
                )
            end
        },
        commands = {
            OrganizeImports = {
                function()
                    local params = {
                        command = "_typescript.organizeImports",
                        arguments = { vim.api.nvim_buf_get_name(0) },
                        title = ""
                    }
                    vim.lsp.buf.execute_command(params)
                end,
                description = "Organize Imports"
            }
        },
    }
end
