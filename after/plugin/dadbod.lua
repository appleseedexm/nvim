vim.g.db_ui_use_nerd_fonts = 1

local function setup_sql_completion()
    local cmp = require('cmp')
    cmp.setup.buffer({ sources = {{ name = 'vim-dadbod-completion' }} })
end

vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'sql', 'mysql', 'plsql' },
    callback = setup_sql_completion,
})
