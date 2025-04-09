local dap = require 'dap'

--if not configs.golangcilsp then
--configs.golangcilsp = {
--default_config = {
--cmd = { 'golangci-lint-langserver' },
--root_dir = lspconfig.util.root_pattern('.git', 'go.mod'),
--init_options = {
--command = { "golangci-lint", "run", "--enable-all", "--disable", "lll", "--out-format", "json", "--issues-exit-code=1" },
--}
--},
--}
--end
--lspconfig.golangci_lint_ls.setup {
--filetypes = { 'go', 'gomod' },
--}

-- gopls
--lspconfig.gopls.setup {
--cmd = { "gopls" },
--filetypes = { "go", "gomod", "gowork", "gotmpl" },
--root_dir = lspconfig.util.root_pattern("go.work", "go.mod", ".git"),
--settings = {
--gopls = {
--completeUnimported = true,
--usePlaceholders = true,
--analyses = {
--unusedparams = true,
--},
--},
--},
--}

-- DAP
dap.adapters.delve = {
    type = 'server',
    port = '${port}',
    executable = {
        command = 'dlv',
        args = { 'dap', '-l', '127.0.0.1:${port}' },
    }
}

-- https://github.com/go-delve/delve/blob/master/Documentation/usage/dlv_dap.md
dap.configurations.go = {
    {
        type = "delve",
        name = "Debug",
        request = "launch",
        program = "${file}"
    },
    {
        type = "delve",
        name = "Debug test", -- configuration for debugging test files
        request = "launch",
        mode = "test",
        program = "${file}"
    },
    -- works with go.mod packages and sub packages
    {
        type = "delve",
        name = "Debug test (go.mod)",
        request = "launch",
        mode = "test",
        program = "./${relativeFileDirname}"
    }
}


local root_dir = vim.fs.root(0, { '.git', 'go.mod' })

return {
    cmd = { "gopls" },
    filetypes = { "go", "gomod", "gowork", "gotmpl" },
    root_dir = root_dir,
    settings = {
        gopls = {
            completeUnimported = true,
            usePlaceholders = true,
            analyses = {
                unusedparams = true,
            },
        },
    }
}
