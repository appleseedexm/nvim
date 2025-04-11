return require('asx.lsp').mk_config({
    cmd = { 'vscode-json-language-server', '--stdio' },
    filetypes = { 'json' },
})
