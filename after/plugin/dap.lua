local dap = require('dap')

vim.keymap.set("n", "<leader>dr", function() require('dap.repl').toggle({ height = 10 }) end)
vim.keymap.set("n", "<leader>db", function() dap.toggle_breakpoint() end)
vim.keymap.set("n", "<leader>dsc", function() dap.continue() end)
vim.keymap.set("n", "<leader>dst", function() dap.terminate() end)
vim.keymap.set("n", "<leader>dsi", function() dap.step_into() end)
vim.keymap.set("n", "<leader>dso", function() dap.step_out() end)
vim.keymap.set("n", "<leader>dsv", function() dap.step_over() end)

