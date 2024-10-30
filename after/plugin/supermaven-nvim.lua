require("supermaven-nvim").setup({
    keymaps = {
        accept_suggestion = "<Tab>",
        clear_suggestion = "<C-]>",
        --accept_word = "<C-b>",
    },
    disable_keymaps = false,
    disable_inline_completion = true,
    ignore_filetypes = {},
    color = {
        suggestion_color = "#ffffff",
        cterm = 244,
    }
})

vim.g.SUPERMAVEN_DISABLED = 1 -- doesnt work with my config
vim.keymap.set("n", "<leader>sm", "<cmd>SupermavenToggle<cr>", { desc = " Toggle Supermaven" })
