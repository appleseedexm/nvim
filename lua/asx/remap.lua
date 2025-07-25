vim.g.mapleader = " "
--vim.keymap.set('n', '<leader>pv', vim.cmd.Ex)

-- remap [[ and ]]
vim.keymap.set("n", "[[", "?{<CR>w99[{")
vim.keymap.set("n", "][", "/}<CR>b99]}")
vim.keymap.set("n", "]]", "j0[[%/{<CR>")
vim.keymap.set("n", "[]", "k$][%?}<CR>")

vim.keymap.set("n", "<C-s>", ":Ag<CR>")

-- zz is op and ZZ is bs
vim.keymap.set("n", "ZZ", "<nop>")

-- copy line location to clipboard
vim.keymap.set("n", "<leader>ll", ":redir @+ | echon '`' . expand('%:h') . '/' . expand('%:t') . ':' . line('.') . '`'   | redir END<CR>")

-- zoom in new tab
vim.keymap.set("n", "<C-w>z", ":tab split<CR>")

-- move code
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- append line below at end of current line without cursor jump
vim.keymap.set("n", "J", "mzJ`z")

-- half-page up and down with centered cursor
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
-- search with centered cursor
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- paste but yank into void register
vim.keymap.set("x", "<leader>p", [["_dP]])

-- yank into system register (asbjornHaland)
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

-- delete into void register
vim.keymap.set({ "n", "v" }, "<leader>-", [["_d]])

vim.keymap.set("n", "Q", "<nop>")
vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tms<CR>")

vim.keymap.set("n", "<A-j>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<A-k>", "<cmd>cprev<CR>zz")
vim.keymap.set("n", "<leader>j", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<leader>k", "<cmd>lprev<CR>zz")
vim.keymap.set("n", "<C-x>", ":lclose<CR>:cclose<CR>")

