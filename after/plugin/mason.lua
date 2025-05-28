local registry = require("mason-registry")

for _, pkg_name in ipairs {
    -- Java
    'java-debug-adapter',
    'java-test',
    'jdtls',
    'vscode-java-decompiler',
    -- Kotlin
    'ktlint',
    'kotlin-language-server',
    -- XML
    'lemminx',
    -- Lua
    'lua-language-server',
    -- Rust
    'rust-analyzer',
    -- Zig
    'zls',
    -- LLVM
    'codelldb',
    -- Lua
    'lua-language-server',
    'luaformatter',
    -- Golang
    'delve',
    'gopls',
    'golangci-lint',
    'golangci-lint-langserver',
    -- Python
    'python-lsp-server',
    -- CSS
    'css-lsp',
    -- GitLab
    'gitlab-ci-ls',
    -- JSON
    'json-lsp',
    -- HTML
    'html-lsp',
    -- JS/TS
    'eslint-lsp',
    'angular-language-server',
    'prettier',
    'typescript-language-server',
    'js-debug-adapater',
} do
    local ok, pkg = pcall(registry.get_package, pkg_name)
    if ok then
        if not pkg:is_installed() then
            pkg:install()
        end
    end
end
