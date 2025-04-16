return require('asx.lsp').mk_config({
    cmd = { 'pylsp' },
    filetypes = { 'python' },
    settings = {
        pylsp = {
            plugins = {
                pycodestyle = {
                    enabled = true,
                },
                pyflakes = {
                    enabled = true,
                },
                rope_completion = {
                    enabled = true,
                },
            },
        }
    },
    setup = {
        function(client)
            client.server_capabilities.documentFormattingProvider = false
            client.server_capabilities.documentRangeFormattingProvider = false
        end
    },
    single_file_support = true,
})
