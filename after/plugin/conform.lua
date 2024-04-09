local conform = require("conform")

conform.setup({
    formatters_by_ft = {
        kotlin = { 'ktlint' },
    },
})

vim.keymap.set("", "<leader>clf", function()
    conform.format({ async = true, lsp_fallback = true })
end)
