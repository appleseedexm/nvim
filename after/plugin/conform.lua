local conform = require("conform")
local home = os.getenv('HOME')

conform.setup({
    formatters = {
        ["google-java-format"] = {
            command = "java",
            prepend_args = { "-jar", home .. "/code/libs/java/google-java-format-1.22.0-all-deps.jar", },
        }
    },
    formatters_by_ft = {
        kotlin = { 'ktlint' },
        java = { 'google-java-format' }
    },
})

vim.keymap.set("", "<leader>clf", function()
    conform.format({ async = true, lsp_format = 'fallback' })
end)
