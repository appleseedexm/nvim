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
        ollama = function()
            return require('codecompanion.adapters').extend("ollama", {
                model = "qwen2.5-coder:32b"
            })
        end
    },
})


vim.keymap.set({ 'n', 'v' }, '<leader>aa', ":CodeCompanionActions<CR>", { noremap = true, buffer = true })
vim.keymap.set({ 'n', 'v' }, '<leader>ac', ":CodeCompanion ", { noremap = true, buffer = true })
