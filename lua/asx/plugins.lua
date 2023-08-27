local Plug = vim.fn['plug#']

vim.call('plug#begin')

-- Core
Plug('nvim-lua/plenary.nvim')
Plug('junegunn/fzf', { ['do'] = vim.fn['fzf#install'] })
Plug('junegunn/fzf.vim')
Plug('nvim-telescope/telescope.nvim')
Plug('nvim-telescope/telescope-fzf-native.nvim', { ['do'] = vim.fn['make'] })
Plug('scrooloose/nerdtree')
Plug('ThePrimeagen/harpoon')

-- Misc
Plug('majutsushi/tagbar')
Plug('kylechui/nvim-surround')
Plug('mbbill/undotree')
Plug('folke/zen-mode.nvim')
Plug("MunifTanjim/nui.nvim")

-- Themes
Plug('rose-pine/neovim')

-- Code
Plug('github/copilot.vim')
Plug('nvim-treesitter/nvim-treesitter', { ['do'] = ':TSUpdate' })
Plug('preservim/nerdcommenter')

-- Git
Plug('tpope/vim-fugitive')
Plug('airblade/vim-gitgutter')
Plug('kdheepak/lazygit.nvim', { lazy = true })
Plug('harrisoncramer/gitlab.nvim', { ['do'] = vim.fn['gitlab#build'] }) -- depends on nui

-- Google Formatter
Plug('google/vim-maktaba')
Plug('google/vim-codefmt')
Plug('google/vim-glaive')

-- LSP
Plug('neovim/nvim-lspconfig')
Plug('williamboman/mason.nvim')
Plug('williamboman/mason-lspconfig.nvim')
Plug('VonHeikemen/lsp-zero.nvim', { branch = 'v2.x' })

-- Autocompletion
Plug('hrsh7th/nvim-cmp')
Plug('hrsh7th/cmp-nvim-lsp')
Plug('L3MON4D3/LuaSnip')

-- JAVA
Plug('mfussenegger/nvim-jdtls')
Plug('mfussenegger/nvim-dap')
Plug('mfussenegger/nvim-dap-ui')



vim.call('plug#end')
