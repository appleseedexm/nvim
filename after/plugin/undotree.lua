local get_open_undotree_buf = function()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        local buf_name = vim.api.nvim_buf_get_name(buf);
        local pwd = vim.fn.getcwd()
        if string.match(buf_name, pwd .. "/undotree_", 1) then
            return buf
        end
    end
    return nil
end

local focus_undotree = function()
    if not get_open_undotree_buf() then
        vim.cmd.UndotreeToggle()
    end
    vim.cmd.UndotreeFocus()
end

local close_undotree = function()
    local buf = get_open_undotree_buf()
    if buf then
        vim.cmd.UndotreeToggle()
        vim.api.nvim_buf_delete(buf, {})
    end
end

vim.keymap.set('n', '<leader>ut', focus_undotree)
vim.keymap.set('n', '<leader>ux', close_undotree)
