vim.g.db_ui_use_nerd_fonts = 1
vim.g.db_ui_execute_on_save = 0

local function setup_sql_completion()
    local cmp = require('cmp')
    cmp.setup.buffer({ sources = { { name = 'vim-dadbod-completion' } } })
end

vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'sql', 'mysql', 'plsql' },
    callback = setup_sql_completion,
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
