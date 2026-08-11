local conform = require("conform")
local home = os.getenv('HOME')

conform.setup({
    notify_on_error = true,
    formatters = {
        ["google-java-format"] = {
            command = "java",
            prepend_args = { "-jar", home .. "/code/libs/java/google-java-format-1.22.0-all-deps.jar", },
        }
    },
    formatters_by_ft = {
        html = { 'eslint_d', 'prettier_d' },
        java = { 'google-java-format' },
        javascript = { 'eslint_d', 'prettier_d' },
        javascriptreact = { 'eslint_d', 'prettier_d' },
        kotlin = { 'ktlint' },
        sql = { 'sqlfmt' },
        typescript = { 'eslint_d', 'prettier_d' },
        typescriptreact = { 'eslint_d', 'prettier_d' },
        vue = { 'eslint_d', 'prettier_d' },
    },
    default_format_opts = {
        lsp_format = 'fallback',
        quiet = false
    }
})

vim.keymap.set("", "<leader>clf", function()
    conform.format({ async = true, lsp_format = 'fallback' })
end)
