local Plug = vim.fn['plug#']

vim.call('plug#begin')

-- Core
Plug('nvim-lua/plenary.nvim')
Plug('junegunn/fzf', { ['do'] = vim.fn['fzf#install'] })
Plug('junegunn/fzf.vim')
Plug('nvim-telescope/telescope.nvim')
Plug('nvim-telescope/telescope-fzf-native.nvim', { ['do'] = vim.fn['make'] })
Plug('nvim-tree/nvim-tree.lua')
Plug('ThePrimeagen/harpoon', { branch = 'harpoon2' })
Plug('stevearc/dressing.nvim')

-- Misc
Plug('nvim-tree/nvim-web-devicons')
Plug('majutsushi/tagbar')
Plug('kylechui/nvim-surround')
Plug('mbbill/undotree')
Plug('folke/zen-mode.nvim')
Plug('MunifTanjim/nui.nvim')
Plug('nvim-lualine/lualine.nvim')
Plug('dahu/vim-fanfingtastic')
Plug('iamcco/markdown-preview.nvim', { ['do'] = 'cd app && npx --yes yarn install' })
Plug('gpanders/editorconfig.nvim')
Plug('epwalsh/obsidian.nvim')
Plug('alexghergh/nvim-tmux-navigation')

-- Themes
Plug('rose-pine/neovim')
Plug('Skullamortis/forest.nvim')
Plug('rebelot/kanagawa.nvim')
Plug('sainnhe/everforest')

-- Code
Plug('supermaven-inc/supermaven-nvim')
Plug('nvim-treesitter/nvim-treesitter', { ['do'] = ':TSUpdate' })
Plug('nvim-treesitter/nvim-treesitter-context')
Plug('nvim-treesitter/nvim-treesitter-textobjects')
Plug('preservim/nerdcommenter')
Plug('mfussenegger/nvim-lint')
Plug('stevearc/conform.nvim')

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
Plug('williamboman/mason-lspconfig.nvim')
Plug('zapling/mason-lock.nvim')
Plug('neovim/nvim-lspconfig')
Plug('VonHeikemen/lsp-zero.nvim', { branch = 'v3.x' })

-- DAP
Plug('mfussenegger/nvim-dap')
Plug('rcarriga/nvim-dap-ui')
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


vim.call('plug#end')
