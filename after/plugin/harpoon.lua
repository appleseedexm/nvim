local harpoon = require("harpoon")

harpoon:setup({
    settings = {
        save_on_toggle = true,
        sync_on_ui_close = false,
        key = function()
            local handle = io.popen("git rev-parse --abbrev-ref HEAD 2> /dev/null")
            local branch_name = handle:read("*a")
            handle:close()
            branch_name = string.gsub(branch_name, "\n", "")
            if branch_name == nil or branch_name == '' then
                return vim.loop.cwd()
            else
                return branch_name .. vim.loop.cwd()
            end
        end,
    }
})

-- basic telescope configuration
local conf = require("telescope.config").values
local function toggle_telescope(harpoon_files)
    local file_paths = {}
    for _, item in ipairs(harpoon_files.items) do
        table.insert(file_paths, item.value)
    end

    require("telescope.pickers").new({}, {
        prompt_title = "Harpoon",
        finder = require("telescope.finders").new_table({
            results = file_paths,
        }),
        previewer = conf.file_previewer({}),
        sorter = conf.generic_sorter({}),
    }):find()
end

harpoon:extend({
    UI_CREATE = function(cx)
        vim.keymap.set("n", "<C-v>", function()
            harpoon.ui:select_menu_item({ vsplit = true })
        end, { buffer = cx.bufnr })

        vim.keymap.set("n", "<C-x>", function()
            harpoon.ui:select_menu_item({ split = true })
        end, { buffer = cx.bufnr })

        vim.keymap.set("n", "<C-t>", function()
            harpoon.ui:select_menu_item({ tabedit = true })
        end, { buffer = cx.bufnr })
    end,
})

vim.keymap.set("n", "<C-e>", function() toggle_telescope(harpoon:list()) end,
    { desc = "Open harpoon window" })


vim.keymap.set("n", "<leader>h", function() harpoon:list():add() end)
vim.keymap.set("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)

-- Toggle previous & next buffers stored within Harpoon list
vim.keymap.set("n", "<A-p>", function() harpoon:list():prev({ ui_nav_wrap = true }) end)
vim.keymap.set("n", "<A-n>", function() harpoon:list():next({ ui_nav_wrap = true }) end)
