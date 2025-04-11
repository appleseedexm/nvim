return require('asx.lsp').mk_config({
    cmd = { 'typescript-language-server', '--stdio' },
    filetypes = { 'typescript', 'javascript' },
    root_dir = vim.fs.root(0, { '.git', 'package.json' })
})
