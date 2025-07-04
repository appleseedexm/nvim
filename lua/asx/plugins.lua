local Plug = vim.fn['plug#']

vim.call('plug#begin')

-- Core
Plug('nvim-lua/plenary.nvim')
Plug('junegunn/fzf', { ['do'] = vim.fn['fzf#install'] })
Plug('junegunn/fzf.vim')
Plug('nvim-telescope/telescope.nvim')
Plug('nvim-telescope/telescope-fzf-native.nvim', { ['do'] = vim.fn['make'] })
Plug('kimabrandt-flx/harpoon', { branch = 'fix_initialization' })
Plug('mikavilpas/yazi.nvim')
Plug('max397574/better-escape.nvim')
Plug('tpope/vim-repeat')
Plug('dahu/vim-fanfingtastic')
Plug('kylechui/nvim-surround')
Plug('alexghergh/nvim-tmux-navigation')
Plug('mbbill/undotree')
Plug('folke/zen-mode.nvim')
Plug('epwalsh/obsidian.nvim')
Plug('tpope/vim-abolish')

-- UI
Plug('stevearc/dressing.nvim')
Plug('nvim-tree/nvim-web-devicons')
Plug('MunifTanjim/nui.nvim')
Plug('nvim-lualine/lualine.nvim')
Plug('folke/which-key.nvim')
Plug('majutsushi/tagbar')


-- Themes
Plug('rose-pine/neovim')
Plug('Skullamortis/forest.nvim')
Plug('rebelot/kanagawa.nvim')
Plug('sainnhe/everforest')
Plug('daltonmenezes/aura-theme', { ['rtp'] = 'packages/neovim' })
Plug('folke/tokyonight.nvim')

-- Code
Plug('iamcco/markdown-preview.nvim', { ['do'] = 'cd app && npx --yes yarn install' })
Plug('gpanders/editorconfig.nvim')
Plug('nvim-treesitter/nvim-treesitter', { ['do'] = ':TSUpdate' })
Plug('nvim-treesitter/nvim-treesitter-context')
Plug('nvim-treesitter/nvim-treesitter-textobjects')
Plug('preservim/nerdcommenter')
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
Plug('zapling/mason-lock.nvim')
Plug('neovim/nvim-lspconfig')

-- DAP
Plug('mfussenegger/nvim-dap')
Plug('rcarriga/nvim-dap-ui')
Plug('theHamsta/nvim-dap-virtual-text')
Plug('nvim-neotest/nvim-nio')

-- Autocompletion
Plug('hrsh7th/nvim-cmp')
Plug('hrsh7th/cmp-nvim-lsp')
Plug('L3MON4D3/LuaSnip')
--
-- Google Formatter
Plug('google/vim-maktaba')
Plug('google/vim-codefmt')
Plug('google/vim-glaive')

-- Java
Plug('mfussenegger/nvim-jdtls')

-- Rust
Plug('simrat39/rust-tools.nvim')

-- Zig
Plug('ziglang/zig.vim')

vim.call('plug#end')
