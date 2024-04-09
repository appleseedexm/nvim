local registry = require("mason-registry")

for _, pkg_name in ipairs {
    -- Java
    'java-debug-adapter',
    'java-test',
    'jdtls',
    -- Kotlin
    'ktlint',
    -- XML
    'lemminx',
    -- Lua
    'lua-language-server',
    -- Rust
    'rust-analyzer',
    'codelldb',
    -- Golang
    'delve',
    'gopls',
    -- JS/TS
    'eslint-lsp',
    'angular-language-server',
    'prettier',
    'typescript-language-server', } do
    local ok, pkg = pcall(registry.get_package, pkg_name)
    if ok then
        if not pkg:is_installed() then
            pkg:install()
        end
    end
end
