local cmd = { 'ngserver' }
local markers = { 'project.json', '.git' }

return require('asx.lsp').mk_config({
    cmd = cmd,
    filetypes = { "typescript", "html", "typescriptreact", "typescript.tsx", "htmlangular" },
    on_new_config = function(new_config, new_root_dir)
        new_config.cmd = cmd
    end,
    root_dir = vim.fs.root(0, markers),
})
