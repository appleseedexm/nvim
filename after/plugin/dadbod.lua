vim.g.db_ui_use_nerd_fonts = 1
vim.g.db_ui_execute_on_save = 0
vim.g.db_ui_disable_mappings = 1

vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'sql', 'mysql', 'plsql' },
    callback = function()
        local cmp = require('cmp')
        cmp.setup.buffer({ sources = { { name = 'vim-dadbod-completion' } } })
        vim.keymap.set('n', '<leader>r', ':normal vip<CR><PLUG>(DBUI_ExecuteQuery)', { buffer = true })
    end
})

vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'dbui' },
    callback = function()
        vim.keymap.set('n', 'R', ':normal vip<CR><PLUG>(DBUI_ExecuteQuery)', { buffer = true })
        vim.keymap.set('n', 'S', '<Plug>(DBUI_SelectLineVsplit)')
        vim.keymap.set('n', 'R', '<Plug>(DBUI_Redraw)')
        vim.keymap.set('n', 'd', '<Plug>(DBUI_DeleteLine)')
        vim.keymap.set('n', 'A', '<Plug>(DBUI_AddConnection)')
        vim.keymap.set('n', 'H', '<Plug>(DBUI_ToggleDetails)')
        vim.keymap.set('n', 'r', '<Plug>(DBUI_RenameLine)')
        vim.keymap.set('n', 'q', '<Plug>(DBUI_Quit)')
        vim.keymap.set('n', 'K', '<Plug>(DBUI_GotoPrevSibling)')
        vim.keymap.set('n', 'J', '<Plug>(DBUI_GotoNextSibling)')
        vim.keymap.set('n', '<C-p>', '<Plug>(DBUI_GotoParentNode)')
        vim.keymap.set('n', '<C-n>', '<Plug>(DBUI_GotoChildNode)')

        local nvim_tmux_nav = require('nvim-tmux-navigation')
        vim.keymap.set('n', "<C-j>", nvim_tmux_nav.NvimTmuxNavigateDown)
        vim.keymap.set('n', "<C-k>", nvim_tmux_nav.NvimTmuxNavigateUp)
    end
})

vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'dbout' },
    callback = function()
        vim.api.nvim_command([[autocmd FileType dbout setlocal nofoldenable]])
    end
})

vim.keymap.set('n', '<leader>bod', function()
    vim.cmd('tabnew')
    vim.cmd('DBUI')
end, {})


vim.api.nvim_command([[autocmd User DBUIOpened setlocal number relativenumber]])
