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
Plug('nvim-tree/nvim-web-devicons')
Plug('majutsushi/tagbar')
Plug('kylechui/nvim-surround')
Plug('mbbill/undotree')
Plug('folke/zen-mode.nvim')
Plug('MunifTanjim/nui.nvim')
Plug('nvim-lualine/lualine.nvim')
Plug('chrisbra/improvedft')
Plug('voldikss/vim-floaterm')
Plug('toppair/peek.nvim', {['do'] = vim.fn['deno task --quiet build:fast']})

-- Themes
Plug('rose-pine/neovim')
Plug('Skullamortis/forest.nvim')

-- Code
Plug('zbirenbaum/copilot.lua', { lazy = true })
Plug('nvim-treesitter/nvim-treesitter', { ['do'] = ':TSUpdate' })
Plug('preservim/nerdcommenter')

-- Git
Plug('tpope/vim-fugitive')
Plug('airblade/vim-gitgutter')
Plug('kdheepak/lazygit.nvim', { lazy = true })
Plug('harrisoncramer/gitlab.nvim',
    { ['do'] = function() require("gitlab.server").build(true) end }) -- depends on nui
Plug('sindrets/diffview.nvim')

-- LSP
Plug('williamboman/mason.nvim')
Plug('williamboman/mason-lspconfig.nvim')
Plug('neovim/nvim-lspconfig')
Plug('VonHeikemen/lsp-zero.nvim', { branch = 'v2.x' })

-- DAP
Plug('mfussenegger/nvim-dap')
Plug('rcarriga/nvim-dap-ui')

-- Autocompletion
Plug('hrsh7th/nvim-cmp')
Plug('hrsh7th/cmp-nvim-lsp')
Plug('L3MON4D3/LuaSnip')
--
-- Google Formatter
Plug('google/vim-maktaba')
Plug('google/vim-codefmt')
Plug('google/vim-glaive')

-- JAVA
Plug('mfussenegger/nvim-jdtls')

-- Rust
Plug('simrat39/rust-tools.nvim')


vim.call('plug#end')
