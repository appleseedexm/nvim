require('mini.visits').setup({
    -- How visit index is converted to list of paths
    list = {
        -- Predicate for which paths to include (all by default)
        filter = nil,

        -- Sort paths based on the visit data (robust frecency by default)
        sort = nil,
    },

    -- Whether to disable showing non-error feedback
    silent = false,

    -- How visit index is stored
    store = {
        -- Whether to write all visits before Neovim is closed
        autowrite = true,

        -- Function to ensure that written index is relevant
        normalize = nil,

        -- Path to store visit index
        path = vim.fn.stdpath('data') .. '/mini-visits-index',
    },

    -- How visit tracking is done
    track = {
        -- Start visit register timer at this event
        -- Supply empty string (`''`) to not do this automatically
        event = 'BufEnter',

        -- Debounce delay after event to register a visit
        delay = 1000,
    },
})


local make_select_path = function(select_global, recency_weight)
    local visits = require('mini.visits')
    local extra = require('mini.extra')
    local sort = visits.gen_sort.default({ recency_weight = recency_weight })
    local select_opts = { sort = sort, preserve_order = true }
    return function()
        select_opts.cwd = select_global and '' or vim.fn.getcwd()
        extra.pickers.visit_paths(select_opts)
    end
end

local map = function(lhs, desc, ...)
    vim.keymap.set('n', lhs, make_select_path(...), { desc = desc })
end

-- Adjust LHS and description to your liking
-- map('<Leader>vr', 'Select recent (all)', true, 1)
map('<Leader>vr', 'Select recent (cwd)', false, 1)
-- map('<Leader>vy', 'Select frecent (all)', true, 0.5)
map('<Leader>vy', 'Select frecent (cwd)', false, 0.5)
-- map('<Leader>vf', 'Select frequent (all)', true, 0)
map('<Leader>vf', 'Select frequent (cwd)', false, 0)

-- branch related
local get_branch = function()
    local branch = vim.fn.system('git rev-parse --abbrev-ref HEAD')
    if vim.v.shell_error ~= 0 then return nil end
    return vim.trim(branch)
end

local map_branch = function(keys, action, desc)
    local rhs = function()
        local branch = get_branch()
        require('mini.visits')[action](branch)
    end
    vim.keymap.set('n', '<Leader>' .. keys, rhs, { desc = desc })
end

map_branch('vb', 'add_label', 'Add branch label')
map_branch('vB', 'remove_label', 'Remove branch label')

vim.keymap.set('n', '<Leader>vc',
    function()
        require("mini.extra").pickers.visit_paths({ filter = get_branch(), preserve_order = true })
    end
    , { desc = "Select branch (cwd)" })

vim.keymap.set('n', '<Leader>vR',
    function()
        require("mini.visits").remove_label(nil, "", "")
    end
    , { desc = "Remove label" })

vim.keymap.set('n', '<Leader>vC',
    function()
        require("mini.visits").remove_label(get_branch(), "", "")
    end
    , { desc = "Remove label of branch" })
