-- Basic autocommands
local config_group = vim.api.nvim_create_augroup("ConfigGroup", {})

-- Auto resize windows
vim.api.nvim_create_autocmd("VimResized", {
    group = config_group,
    callback = function()
        vim.cmd("tabdo wincmd =")
    end,
})

-- Create dir on save
vim.api.nvim_create_autocmd("BufWritePre", {
  group = config_group,
  callback = function()
    local dir = vim.fn.expand('<afile>:p:h')
    if vim.fn.isdirectory(dir) == 0 then
      vim.fn.mkdir(dir, 'p')
    end
  end,
})

