vim.keymap.set("n", "<leader>dr", function() require('dap.repl').toggle({ height = 10 }) end )
vim.keymap.set("n", "<leader>db", function() require('dap').toggle_breakpoint() end )
