local telescope = require('telescope')
local previewers = require('telescope.previewers')
local builtin = require('telescope.builtin')
local action_layout = require('telescope.actions.layout')
local actions = require('telescope.actions')
local fzf_workspace_opts = {
    fuzzy = false,                  -- false will only do exact matching
    override_generic_sorter = true, -- override the generic sorter
    override_file_sorter = true,    -- override the file sorter
    case_mode = "smart_case",       -- or "ignore_case" or "respect_case"
    -- the default case_mode is "smart_case"
}

local function is_workspace_git_repo()
    return vim.fn.isdirectory(vim.fn.getcwd() .. "/.git") == 1
end

local delta = previewers.new_termopen_previewer {
    get_command = function(entry)
        return { 'git', '-c', 'core.pager=delta', '-c', 'delta.side-by-side=false', 'diff', entry.value .. '^!' }
    end
}

local my_git_commits = function(opts)
    opts = opts or {}
    opts.previewer = {
        delta,
        previewers.git_commit_message.new(opts),
        previewers.git_commit_diff_as_was.new(opts),
    }

    builtin.git_commits(opts)
end

local my_git_bcommits = function(opts)
    opts = opts or {}
    opts.previewer = {
        delta,
        previewers.git_commit_message.new(opts),
        previewers.git_commit_diff_as_was.new(opts),
    }

    builtin.git_bcommits(opts)
end

vim.keymap.set('n', '<leader>tf', function() builtin.find_files({ no_ignore = true, hidden = true }) end, {})
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
    builtin.grep_string({ search = vim.fn.input("Grep string > "), additional_args = { '-i.' } })
end)
vim.keymap.set('n', '<leader>tww', function()
    builtin.lsp_workspace_symbols({ query = vim.fn.input("Grep lsp workspace symbols > ") })
end)
vim.keymap.set('n', '<leader>th', builtin.help_tags, {})
vim.keymap.set('n', '<leader>tb', builtin.buffers, {})
vim.keymap.set('n', '<leader>to', builtin.lsp_document_symbols, {})
vim.keymap.set('n', '<leader>twd', builtin.lsp_dynamic_workspace_symbols, {})
vim.keymap.set('n', '<leader>trf', builtin.lsp_references, {})
vim.keymap.set('n', '<leader>td', builtin.lsp_type_definitions, {})
vim.keymap.set('n', '<leader>trs', builtin.resume, {})
vim.keymap.set("n", "<leader>tgb", my_git_bcommits, {})
vim.keymap.set("n", "<leader>tgc", my_git_commits, {})
vim.keymap.set("n", "<leader>tgs", builtin.git_status, {})

local pickers = {

    current_buffer_tags = { fname_width = 100, },

    jumplist = { fname_width = 100, },

    loclist = { fname_width = 100, },

    lsp_definitions = { fname_width = 100, },

    lsp_document_symbols = { fname_width = 100, symbol_width = 140, show_line = true },

    lsp_dynamic_workspace_symbols = { fname_width = 100, symbol_width = 140, show_line = true, sorter = telescope.extensions.fzf.native_fzf_sorter(fzf_workspace_opts) },

    lsp_implementations = { fname_width = 100, },

    lsp_incoming_calls = { fname_width = 100, },

    lsp_outgoing_calls = { fname_width = 100, },

    lsp_references = { fname_width = 100, show_line = false },

    lsp_type_definitions = { fname_width = 100, },

    lsp_workspace_symbols = { fname_width = 100, symbol_width = 140, show_line = true },

    quickfix = { fname_width = 100, },

    tags = { fname_width = 100, },

}

telescope.setup(
    {
        defaults = {
            sorting_strategy = "ascending",
            layout_strategy = "vertical",
            wrap_result = true,
            mappings = {
                n = {
                    ["<C-y>"] = action_layout.toggle_preview,
                    ["<leader><leader>"] = actions.close
                },
                i = {
                    ["<C-y>"] = action_layout.toggle_preview,
                    ["<C-s>"] = actions.cycle_previewers_next,
                },
            },
        },
        pickers = pickers,
    }
)

require('telescope').load_extension('fzf')
