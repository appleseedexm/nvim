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

