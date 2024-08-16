local telescope = require('telescope')

local builtin = require('telescope.builtin')

local function is_workspace_git_repo()
    return vim.fn.isdirectory(vim.fn.getcwd() .. "/.git") == 1
end

if is_workspace_git_repo() then
    vim.keymap.set('n', '<C-p>', builtin.git_files, {})
end
vim.keymap.set('n', '<leader>tf', builtin.find_files, {})
vim.keymap.set('n', '<C-p>',
    function()
        if is_workspace_git_repo() then
            builtin.git_files()
        else
            builtin.find_files()
        end
    end,
    {})
vim.keymap.set('n', '<leader>ts', function()
    builtin.grep_string({ search = vim.fn.input("Grep > ") })
end)
vim.keymap.set('n', '<leader>th', builtin.help_tags, {})
vim.keymap.set('n', '<leader>tb', builtin.buffers, {})
vim.keymap.set('n', '<leader>to', builtin.lsp_document_symbols, {})
vim.keymap.set('n', '<leader>twd', builtin.lsp_dynamic_workspace_symbols, {})
vim.keymap.set('n', '<leader>tww', builtin.lsp_workspace_symbols, {})
vim.keymap.set('n', '<leader>trf', builtin.lsp_references, {})
vim.keymap.set('n', '<leader>td', builtin.lsp_type_definitions, {})
vim.keymap.set('n', '<leader>trs', builtin.resume, {})
vim.keymap.set("n", "<leader>tgc", builtin.git_bcommits, {})
vim.keymap.set("n", "<leader>tgs", builtin.git_status, {})

local pickers = {

    current_buffer_tags = { fname_width = 100, },

    jumplist = { fname_width = 100, },

    loclist = { fname_width = 100, },

    lsp_definitions = { fname_width = 100, },

    lsp_document_symbols = { fname_width = 100, symbol_width = 140, },

    lsp_dynamic_workspace_symbols = { fname_width = 100, },

    lsp_implementations = { fname_width = 100, },

    lsp_incoming_calls = { fname_width = 100, },

    lsp_outgoing_calls = { fname_width = 100, },

    lsp_references = { fname_width = 100, show_line = false },

    lsp_type_definitions = { fname_width = 100, },

    lsp_workspace_symbols = { fname_width = 100, },

    quickfix = { fname_width = 100, },

    tags = { fname_width = 100, },

}

telescope.setup(
    {
        defaults = {
            sorting_strategy = "ascending",
            layout_strategy = "vertical",
            wrap_result = true
        }
        ,
        pickers = pickers
    }
)

require('telescope').load_extension('fzf')
