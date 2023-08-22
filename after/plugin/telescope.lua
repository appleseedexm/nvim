require('telescope').load_extension('fzf')

local telescope = require('telescope')

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>pf', builtin.find_files, {})
vim.keymap.set('n', '<C-p>', builtin.git_files, {})
vim.keymap.set('n', '<leader>ps', function()
    builtin.grep_string({ search = vim.fn.input("Grep > ") })
end)
vim.keymap.set('n', '<leader>vh', builtin.help_tags, {})


telescope.setup(
    {
        defaults = {
            sorting_strategy = "ascending",
            layout_strategy = "vertical",
            wrap_result = true
        }
    }
)
