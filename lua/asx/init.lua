
require('asx.plugins')
require('asx.remap')
require('asx.set')

require('telescope').load_extension('fzf')
require('mason').setup()

-- Glaive / codefmt
vim.call('glaive#Install')
vim.cmd('source /home/dev/.config/nvim/lua/asx/glaive.vim')

--  local telescope = require('telescope.builtin')
-- vim.keymap.set('n', 'C-p', telescope.git_files, {})


