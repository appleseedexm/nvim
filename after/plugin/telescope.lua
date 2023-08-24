require('telescope').load_extension('fzf')

local telescope = require('telescope')

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>pf', builtin.find_files, {})
vim.keymap.set('n', '<C-p>', builtin.git_files, {})
vim.keymap.set('n', '<leader>ps', function()
    builtin.grep_string({ search = vim.fn.input("Grep > ") })
end)
vim.keymap.set('n', '<leader>th', builtin.help_tags, {})
vim.keymap.set('n', '<leader>to', builtin.lsp_document_symbols, {})
vim.keymap.set('n', '<leader>tr', builtin.lsp_references, {})
vim.keymap.set('n', '<leader>td', builtin.lsp_type_definitions, {})

telescope.setup(
    {
        defaults = {
            sorting_strategy = "ascending",
            layout_strategy = "vertical",
            wrap_result = true
        }
    }
)
