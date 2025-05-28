return require('asx.lsp').mk_config({
    cmd = { "zls" },
    filetypes = { "zig", "zir" },
    settings = {
        semantic_tokens = "partial",
    }
})
