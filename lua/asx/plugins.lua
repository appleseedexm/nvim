local Plug = vim.fn['plug#']

vim.call('plug#begin')

Plug('junegunn/fzf', { ['do'] = vim.fn['fzf#install'] })
Plug('junegunn/fzf.vim')
Plug('nvim-lua/plenary.nvim')
Plug('nvim-telescope/telescope.nvim')
Plug('nvim-telescope/telescope-fzf-native.nvim', { ['do'] = vim.fn['make'] })
Plug('tpope/vim-surround')
Plug('scrooloose/nerdtree')
Plug('scrooloose/syntastic')
Plug('airblade/vim-gitgutter')
Plug('majutsushi/tagbar')
Plug('folke/which-key.nvim', { lazy = true })
Plug('tpope/vim-fugitive')
Plug('rose-pine/neovim')
Plug('nvim-lua/plenary.nvim')
Plug('kdheepak/lazygit.nvim', { lazy = true })
Plug('nvim-treesitter/nvim-treesitter', { ['do'] = ':TSUpdate'} )
Plug('github/copilot.vim')
Plug('mbbill/undotree')
Plug('folke/zen-mode.nvim')


-- LSP
Plug('neovim/nvim-lspconfig')
Plug('williamboman/mason.nvim')
Plug('williamboman/mason-lspconfig.nvim')

-- Autocompletion
Plug('hrsh7th/nvim-cmp')
Plug('hrsh7th/cmp-nvim-lsp')
Plug('L3MON4D3/LuaSnip')
Plug('VonHeikemen/lsp-zero.nvim', { branch = 'v2.x' })

-- JAVA
Plug('mfussenegger/nvim-jdtls')
Plug('mfussenegger/nvim-dap')
Plug('mfussenegger/nvim-dap-ui')



vim.call('plug#end')
