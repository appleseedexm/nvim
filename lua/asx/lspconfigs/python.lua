return function(args, markers)
    local util = require 'lspconfig.util'
    local extension_path = require('mason-registry')
        .get_package('python-lsp-server')
        :get_install_path()
    local cmd = extension_path .. "/venv/bin/pylsp"

    return {
        cmd = { cmd },
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
    }
end
