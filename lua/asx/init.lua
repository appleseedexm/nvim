vim.cmd("source ".. vim.fn.expand('~/.config/nvim/lua/asx/bigfile.vim'))

require('asx.plugins')
require('asx.remap')
require('asx.set')
require('asx.extend')

require('asx.lsp').enable()
