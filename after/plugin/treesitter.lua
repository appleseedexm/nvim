local languages = { "lua", "rust", "toml", "java", "javascript", "typescript", "json", "html", "xml", "zig", "css",
    "python", };

local ts = require('nvim-treesitter')
ts.install(languages)
vim.api.nvim_create_autocmd('FileType', {
    group = vim.api.nvim_create_augroup('treesitter.setup', {}),
    callback = function(args)
        local buf = args.buf
        local filetype = args.match

        -- you need some mechanism to avoid running on buffers that do not
        -- correspond to a language (like oil.nvim buffers), this implementation
        -- checks if a parser exists for the current language
        local language = vim.treesitter.language.get_lang(filetype) or filetype
        if not vim.treesitter.language.add(language) then
            return
        end

        -- replicate `fold = { enable = true }`
        vim.wo.foldmethod = 'expr'
        vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'

        -- replicate `highlight = { enable = true }`
        vim.treesitter.start(buf, language)

        -- replicate `indent = { enable = true }`
        vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"

        -- `incremental_selection = { enable = true }` cannot be easily replicated
    end,
})

-- fallback until there is a better replacement
local tm = require('treesitter-modules')
tm.setup({
    incremental_selection = { enable = true }
})
vim.keymap.set("v", "v", tm.node_incremental)
vim.keymap.set("v", "V", tm.node_decremental)

local context = require('treesitter-context')
context.setup {
    enable = true,            -- Enable this plugin (Can be enabled/disabled later via commands)
    max_lines = 0,            -- How many lines the window should span. Values <= 0 mean no limit.
    min_window_height = 0,    -- Minimum editor window height to enable context. Values <= 0 mean no limit.
    line_numbers = true,
    multiline_threshold = 20, -- Maximum number of lines to show for a single context
    trim_scope = 'outer',     -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
    mode = 'cursor',          -- Line used to calculate context. Choices: 'cursor', 'topline'
    -- Separator between context and content. Should be a single character string, like '-'.
    -- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
    separator = nil,
    zindex = 20,     -- The Z-index of the context window
    on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
}
vim.keymap.set("n", "[c", function()
    context.go_to_context(vim.v.count1)
end, { silent = true })

local textobjects = require('nvim-treesitter-textobjects')
textobjects.setup {
    select = {
        -- Automatically jump forward to textobj, similar to targets.vim
        lookahead = true,
        -- You can choose the select mode (default is charwise 'v')
        --
        -- Can also be a function which gets passed a table with the keys
        -- * query_string: eg '@function.inner'
        -- * method: eg 'v' or 'o'
        -- and should return the mode ('v', 'V', or '<c-v>') or a table
        -- mapping query_strings to modes.
        selection_modes = {
            ['@parameter.outer'] = 'v', -- charwise
            ['@function.outer'] = 'V',  -- linewise
            -- ['@class.outer'] = '<c-v>', -- blockwise
        },
        -- If you set this to `true` (default is `false`) then any textobject is
        -- extended to include preceding or succeeding whitespace. Succeeding
        -- whitespace has priority in order to act similarly to eg the built-in
        -- `ap`.
        --
        -- Can also be a function which gets passed a table with the keys
        -- * query_string: eg '@function.inner'
        -- * selection_mode: eg 'v'
        -- and should return true of false
        include_surrounding_whitespace = false,
    },
    move = {
        enable = true,
        set_jumps = true, -- whether to set jumps in the jumplist
    },
}
-- select
vim.keymap.set({ "x", "o" }, "am", function()
    require "nvim-treesitter-textobjects.select".select_textobject("@function.outer", "textobjects")
end)
vim.keymap.set({ "x", "o" }, "im", function()
    require "nvim-treesitter-textobjects.select".select_textobject("@function.inner", "textobjects")
end)
vim.keymap.set({ "x", "o" }, "ac", function()
    require "nvim-treesitter-textobjects.select".select_textobject("@class.outer", "textobjects")
end)
vim.keymap.set({ "x", "o" }, "ic", function()
    require "nvim-treesitter-textobjects.select".select_textobject("@class.inner", "textobjects")
end)
-- You can also use captures from other query groups like `locals.scm`
vim.keymap.set({ "x", "o" }, "as", function()
    require "nvim-treesitter-textobjects.select".select_textobject("@local.scope", "locals")
end)
-- move
vim.keymap.set({ "n", "x", "o" }, "]m", function()
    require("nvim-treesitter-textobjects.move").goto_next_start("@function.outer", "textobjects")
end)
vim.keymap.set({ "n", "x", "o" }, "]]", function()
    require("nvim-treesitter-textobjects.move").goto_next_start("@class.outer", "textobjects")
end)
-- You can also pass a list to group multiple queries.
vim.keymap.set({ "n", "x", "o" }, "]o", function()
    move.goto_next_start({ "@loop.inner", "@loop.outer" }, "textobjects")
end)
-- You can also use captures from other query groups like `locals.scm` or `folds.scm`
vim.keymap.set({ "n", "x", "o" }, "]s", function()
    require("nvim-treesitter-textobjects.move").goto_next_start("@local.scope", "locals")
end)
vim.keymap.set({ "n", "x", "o" }, "]z", function()
    require("nvim-treesitter-textobjects.move").goto_next_start("@fold", "folds")
end)
vim.keymap.set({ "n", "x", "o" }, "]M", function()
    require("nvim-treesitter-textobjects.move").goto_next_end("@function.outer", "textobjects")
end)
vim.keymap.set({ "n", "x", "o" }, "][", function()
    require("nvim-treesitter-textobjects.move").goto_next_end("@class.outer", "textobjects")
end)
vim.keymap.set({ "n", "x", "o" }, "[m", function()
    require("nvim-treesitter-textobjects.move").goto_previous_start("@function.outer", "textobjects")
end)
vim.keymap.set({ "n", "x", "o" }, "[[", function()
    require("nvim-treesitter-textobjects.move").goto_previous_start("@class.outer", "textobjects")
end)
vim.keymap.set({ "n", "x", "o" }, "[M", function()
    require("nvim-treesitter-textobjects.move").goto_previous_end("@function.outer", "textobjects")
end)
vim.keymap.set({ "n", "x", "o" }, "[]", function()
    require("nvim-treesitter-textobjects.move").goto_previous_end("@class.outer", "textobjects")
end)
-- Go to either the start or the end, whichever is closer.
-- Use if you want more granular movements
vim.keymap.set({ "n", "x", "o" }, "]n", function()
    require("nvim-treesitter-textobjects.move").goto_next("@conditional.outer", "textobjects")
end)
vim.keymap.set({ "n", "x", "o" }, "[n", function()
    require("nvim-treesitter-textobjects.move").goto_previous("@conditional.outer", "textobjects")
end)
-- swap
vim.keymap.set("n", "<leader>a", function()
    require("nvim-treesitter-textobjects.swap").swap_next "@parameter.inner"
end)
vim.keymap.set("n", "<leader>A", function()
    require("nvim-treesitter-textobjects.swap").swap_previous "@parameter.outer"
end)
