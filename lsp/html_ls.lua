return require('asx.lsp').mk_config({
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
    root_dir = vim.fs.root(0, { '.git', 'package.json' }),
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
})
