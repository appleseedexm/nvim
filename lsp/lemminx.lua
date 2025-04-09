local cmd = require('mason-registry')
    .get_package('lemminx')
    :get_install_path()
    .. "/lemminx-linux"

return {
    cmd = { cmd },
    root_markers = {},
    filetypes = { 'xml' },
    settings = {
        xml = {
            server = {
                workDir = "~/.cache/lemminx",
            }
        }
    }
}
