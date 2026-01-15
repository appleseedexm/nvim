require("codecompanion").setup({
    strategies = {
        inline = {
            adapter = "ollama"
        },
        chat = {
            adapter = "ollama"
        }
    },
    adapters = {
        http = {
            ollama = function()
                return require('codecompanion.adapters').extend("ollama", {
                    model = "codellama:34b"
                })
            end
        }
    },
})

vim.keymap.set({ 'n', 'v' }, '<leader>caa', ":CodeCompanionActions<CR>",
    { desc = "Run Code Companion Actions" })
vim.keymap.set({ 'n', 'v' }, '<leader>cac', ":CodeCompanion ",
    { desc = "Start Code Companion" })
vim.keymap.set({ 'n', 'v' }, '<leader>cah', ":CodeCompanionChat<CR>",
    { desc = "Open Code Companion Chat" })
