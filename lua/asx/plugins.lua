local Plug = vim.fn['plug#']

vim.call('plug#begin')

-- Core
Plug('nvim-lua/plenary.nvim')
Plug('junegunn/fzf', { ['do'] = vim.fn['fzf#install'] })
Plug('junegunn/fzf.vim')
Plug('nvim-telescope/telescope.nvim')
Plug('nvim-telescope/telescope-fzf-native.nvim', { ['do'] = vim.fn['make'] })
Plug('mikavilpas/yazi.nvim')
Plug('tpope/vim-repeat')       -- multiline & repeatable f/t/;/
Plug('dahu/vim-fanfingtastic') -- multiline & repeatable f/t/;/
Plug('kylechui/nvim-surround')
Plug('alexghergh/nvim-tmux-navigation')
Plug('mbbill/undotree')
Plug('folke/zen-mode.nvim')
Plug('epwalsh/obsidian.nvim')
Plug('nvim-mini/mini.visits')
Plug('nvim-mini/mini.extra')
Plug('nvim-mini/mini.pairs')

-- UI
Plug('nvim-mini/mini.statusline')
Plug('folke/which-key.nvim')
Plug('nvim-mini/mini.pick')

-- Themes
Plug('rose-pine/neovim')
Plug('Skullamortis/forest.nvim')
Plug('rebelot/kanagawa.nvim')
Plug('sainnhe/everforest')
Plug('folke/tokyonight.nvim')
Plug('webhooked/kanso.nvim')
Plug('morhetz/gruvbox')

-- Code
Plug('nvim-treesitter/nvim-treesitter', { ['do'] = ':TSUpdate', ['branch'] = 'main' })
Plug('nvim-treesitter/nvim-treesitter-context')
Plug('nvim-treesitter/nvim-treesitter-textobjects', { ['branch'] = 'main' })
Plug('MeanderingProgrammer/treesitter-modules.nvim')
Plug('numToStr/Comment.nvim')
Plug('mfussenegger/nvim-lint')
Plug('stevearc/conform.nvim')
Plug('folke/lazydev.nvim')
Plug('olimorris/codecompanion.nvim')

-- SQL
Plug('tpope/vim-dadbod', { lazy = true })
Plug('kristijanhusak/vim-dadbod-ui', { lazy = true })
Plug('kristijanhusak/vim-dadbod-completion', { lazy = true })

-- Git
Plug('tpope/vim-fugitive')
Plug('airblade/vim-gitgutter')
Plug('kdheepak/lazygit.nvim', { lazy = true })
Plug('sindrets/diffview.nvim')

-- LSP
Plug('williamboman/mason.nvim')
Plug('neovim/nvim-lspconfig')

-- DAP
Plug('mfussenegger/nvim-dap')
Plug('rcarriga/nvim-dap-ui')
Plug('theHamsta/nvim-dap-virtual-text')
Plug('nvim-neotest/nvim-nio')

-- Autocompletion
Plug('nvim-mini/mini.completion')
Plug('L3MON4D3/LuaSnip')

---- LANGUAGES ----

-- Java
Plug('mfussenegger/nvim-jdtls')

-- Rust
Plug('simrat39/rust-tools.nvim')

-- Typescript
Plug('dmmulroy/ts-error-translator.nvim')

-- Zig
Plug('ziglang/zig.vim')

vim.call('plug#end')
