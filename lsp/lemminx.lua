return require('asx.lsp').mk_config({
    cmd = { "lemminx" },
    root_markers = {},
    filetypes = { 'xml' },
    settings = {
        xml = {
            server = {
                workDir = "~/.cache/lemminx",
            }
        }
    }
})
