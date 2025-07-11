--vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- cursor
vim.opt.guicursor =
-- "n-v-c:block,i-ci-ve:block,r-cr:hor20,o:hor50,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor,sm:block-blinkwait175-blinkoff150-blinkon175"
"n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20,t:block-blinkon500-blinkoff500-TermCursor"
-- "n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor,sm:block-blinkwait175-blinkoff150-blinkon175"
vim.opt.cursorline = true
vim.opt.cursorlineopt = "number"
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8

-- files
vim.opt.hidden = true
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("XDG_DATA_HOME") .. "/nvim/undodir"
vim.opt.undofile = true
vim.opt.isfname:append("@-@")
vim.opt.autoread = true
vim.opt.autowrite = false

-- ui
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes"
vim.opt.colorcolumn = "80"
vim.opt.wrap = false
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.winfixheight = false
vim.opt.conceallevel = 0
vim.opt.concealcursor = ""
vim.opt.showmode = false
vim.opt.cmdheight = 1
vim.opt.errorbells = false

-- behavior
vim.opt.selection = 'exclusive'
vim.opt.encoding = 'utf-8'
vim.opt.showmatch = false
vim.opt.matchtime = 5
vim.opt.foldmethod = "expr"
vim.wo.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldlevel = 99

-- format
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true

-- search
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- engine
vim.opt.termguicolors = true
vim.opt.updatetime = 50
vim.opt.timeoutlen = 500
vim.opt.shell = "/bin/zsh"
vim.opt.title = true
vim.opt.titlestring = [[%t%( %M%) - nvim]]
vim.opt.redrawtime = 1000
vim.opt.maxmempattern = 20000
