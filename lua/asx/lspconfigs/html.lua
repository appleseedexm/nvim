return function(args, markers)
    return {
        name = "vscode-html-language-server",
        on_attach = function(client, bufnr)
            vim.api.nvim_create_user_command(
                "RelativeCodeFormat",
                function()
                    print("FormatCode")
                    vim.cmd("FormatCode")
                end,
                {}
            )
        end,
        cmd = { 'vscode-html-language-server', '--stdio' },
        filetypes = { 'html', 'htmldjango', 'htmljinja', 'svelte', 'vue', 'windi' },
        init_options = {
            provideFormatter = true,
            provideHover = true,
            provideCompletionItem = true,
            provideCompletionItemResolve = true,
            provideDocumentFormattingEdits = true,
            provideDocumentRangeFormattingEdits = true,
            provideRenameEdits = true,
            provideSignatureHelp = true,
            emmetCompletions = true,
        },
        settings = {
            html = {
                format = {
                    enabled = false,
                },
                validate = {
                    scripts = true,
                    styles = true,
                },
                suggest = {
                    html5 = true,
                }
            }
        },
    }
end
