vim.g.db_ui_use_nerd_fonts = 1
vim.g.db_ui_execute_on_save = 0
vim.g.db_ui_disable_mappings = 0

-- since we dont use a lsp this wont interfere with mini.completion
vim.api.nvim_command([[autocmd FileType sql setlocal omnifunc=vim_dadbod_completion#omni]])
vim.api.nvim_command([[autocmd FileType mysql setlocal omnifunc=vim_dadbod_completion#omni]])
vim.api.nvim_command([[autocmd FileType plsql setlocal omnifunc=vim_dadbod_completion#omni]])

vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'sql', 'mysql', 'plsql' },
    callback = function(args)
        vim.keymap.set('n', '<leader>r', ':normal vip<CR><PLUG>(DBUI_ExecuteQuery)', { buffer = true })
    end
})

vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'dbui' },
    callback = function()
        --vim.keymap.set('n', 'R', ':normal vip<CR><PLUG>(DBUI_ExecuteQuery)', { buffer = true })
        --vim.keymap.set('n', 'S', '<Plug>(DBUI_SelectLineVsplit)', { buffer = true })
        --vim.keymap.set('n', '<CR>', '<Plug>(DBUI_SelectLine)', { buffer = true })
        --vim.keymap.set('n', 'R', '<Plug>(DBUI_Redraw)', { buffer = true })
        --vim.keymap.set('n', 'd', '<Plug>(DBUI_DeleteLine)', { buffer = true })
        --vim.keymap.set('n', 'A', '<Plug>(DBUI_AddConnection)', { buffer = true })
        --vim.keymap.set('n', 'H', '<Plug>(DBUI_ToggleDetails)', { buffer = true })
        --vim.keymap.set('n', 'r', '<Plug>(DBUI_RenameLine)', { buffer = true })
        --vim.keymap.set('n', 'q', '<Plug>(DBUI_Quit)', { buffer = true })
        --vim.keymap.set('n', 'K', '<Plug>(DBUI_GotoPrevSibling)', { buffer = true })
        --vim.keymap.set('n', 'J', '<Plug>(DBUI_GotoNextSibling)', { buffer = true })
        --vim.keymap.set('n', '<C-p>', '<Plug>(DBUI_GotoParentNode)', { buffer = true })
        --vim.keymap.set('n', '<C-n>', '<Plug>(DBUI_GotoChildNode)', { buffer = true })

        local nvim_tmux_nav = require('nvim-tmux-navigation')
        vim.keymap.set('n', "<C-j>", nvim_tmux_nav.NvimTmuxNavigateDown, { buffer = true })
        vim.keymap.set('n', "<C-k>", nvim_tmux_nav.NvimTmuxNavigateUp, { buffer = true })
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
