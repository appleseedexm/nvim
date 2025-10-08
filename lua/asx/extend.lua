-- Basic autocommands
local config_group = vim.api.nvim_create_augroup("ConfigGroup", {})

-- Auto resize windows
vim.api.nvim_create_autocmd("VimResized", {
    group = config_group,
    callback = function()
        local cur_tab = vim.api.nvim_get_current_tabpage()
        vim.cmd("tabdo wincmd =")
        vim.cmd("tabnext " .. cur_tab)
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

-- fix CR, see https://github.com/echasnovski/mini.nvim/issues/1469
local keycode = vim.keycode or function(x)
    return vim.api.nvim_replace_termcodes(x, true, true, true)
end
local keys = {
    ['cr']        = keycode('<CR>'),
    ['ctrl-y']    = keycode('<C-y>'),
    ['ctrl-y_cr'] = keycode('<C-y><CR>'),
}

_G.cr_action = function()
    if vim.fn.pumvisible() ~= 0 then
        -- If popup is visible, confirm selected item or add new line otherwise
        local item_selected = vim.fn.complete_info()['selected'] ~= -1
        return item_selected and keys['ctrl-y'] or keys['ctrl-y_cr']
    else
        -- If popup is not visible, use plain `<CR>`. You might want to customize
        -- according to other plugins. For example, to use 'mini.pairs', replace
        -- next line with `return require('mini.pairs').cr()`
        return keys['cr']
    end
end

vim.keymap.set('i', '<CR>', 'v:lua._G.cr_action()', { expr = true })
