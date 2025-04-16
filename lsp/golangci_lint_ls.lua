local root_dir = vim.fs.root(0, { '.git', 'go.mod' })

return {
    cmd = { 'golangci-lint-langserver' },
    root_dir = root_dir,
    filetypes = { 'go', 'gomod' },
    init_options = {
        command = { "golangci-lint", "run", "--output.json.path=stdout", "--show-stats=false" }
    },
}
