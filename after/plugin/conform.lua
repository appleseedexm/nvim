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
        html = { 'prettier' },
        java = { 'google-java-format' },
        javascript = { 'prettier' },
        javascriptreact = { 'prettier' },
        kotlin = { 'ktlint' },
        sql = { 'sqlfmt' },
        typescript = { 'prettier' },
        typescriptreact = { 'prettier' },
        vue = { 'prettier' },
    },
    default_format_opts = {
        lsp_format = 'fallback',
        quiet = false
    }
})

vim.keymap.set("", "<leader>clf", function()
    conform.format({ async = true, lsp_format = 'fallback' })
end)
