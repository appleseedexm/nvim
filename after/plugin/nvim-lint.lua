local lint = require("lint")

lint.linters_by_ft = {
    kotlin = { 'ktlint' },
}

vim.keymap.set("", "<leader>cll", function()
    lint.try_lint()
end)
