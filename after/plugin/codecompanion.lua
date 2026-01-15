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

vim.keymap.set({ 'n', 'v' }, '<leader>aa', ":CodeCompanionActions<CR>", { noremap = true, buffer = true, desc = "Run Code Companion Actions" })
vim.keymap.set({ 'n', 'v' }, '<leader>ac', ":CodeCompanion ", { noremap = true, buffer = true, desc = "Start Code Companion" })
vim.keymap.set({ 'n', 'v' }, '<leader>ah', ":CodeCompanionChat<CR>", { noremap = true, buffer = true, desc = "Open Code Companion Chat" })
