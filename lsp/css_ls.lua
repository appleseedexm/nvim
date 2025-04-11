return require('asx.lsp').mk_config({
    cmd = { 'vscode-css-language-server', '--stdio' },
    filetypes = { 'css', 'scss' },
})
