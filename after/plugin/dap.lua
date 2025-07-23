local dap = require('dap')
local whichkey = require("which-key")
local dapui = require("dapui")

-- which-key
local keymap = {
    { "<leader>d",  group = "DAP" },
    { "<leader>dR", "<cmd>lua require'dap'.run_to_cursor()<cr>",                               desc = "Run to Cursor" },
    { "<leader>dE", "<cmd>lua require'dapui'.eval(vim.fn.input '[Expression] > ')<cr>",        desc = "Evaluate Input" },
    { "<leader>dC", "<cmd>lua require'dap'.set_breakpoint(vim.fn.input '[Condition] > ')<cr>", desc = "Conditional Breakpoint" },
    { "<leader>dU", "<cmd>lua require'dapui'.toggle()<cr>",                                    desc = "Toggle UI" },
    { "<leader>db", "<cmd>lua require'dap'.step_back()<cr>",                                   desc = "Step Back" },
    { "<leader>dc", "<cmd>lua require'dap'.continue()<cr>",                                    desc = "Continue" },
    { "<leader>dd", "<cmd>lua require'dap'.disconnect()<cr>",                                  desc = "Disconnect" },
    { "<leader>de", "<cmd>lua require'dapui'.eval()<cr>",                                      desc = "Evaluate" },
    { "<leader>dg", "<cmd>lua require'dap'.session()<cr>",                                     desc = "Get Session" },
    { "<leader>dh", "<cmd>lua require'dap.ui.widgets'.hover()<cr>",                            desc = "Hover Variables" },
    { "<leader>dS", "<cmd>lua require'dap.ui.widgets'.scopes()<cr>",                           desc = "Scopes" },
    { "<leader>di", "<cmd>lua require'dap'.step_into()<cr>",                                   desc = "Step Into" },
    { "<leader>do", "<cmd>lua require'dap'.step_over()<cr>",                                   desc = "Step Over" },
    { "<leader>dp", "<cmd>lua require'dap'.pause.toggle()<cr>",                                desc = "Pause" },
    { "<leader>dq", "<cmd>lua require'dap'.close()<cr>",                                       desc = "Quit" },
    { "<leader>dr", "<cmd>lua require'dap'.repl.toggle()<cr>",                                 desc = "Toggle Repl" },
    { "<leader>ds", "<cmd>lua require'dap'.continue()<cr>",                                    desc = "Start" },
    { "<leader>dt", "<cmd>lua require'dap'.toggle_breakpoint()<cr>",                           desc = "Toggle Breakpoint" },
    { "<leader>dx", "<cmd>lua require'dap'.terminate()<cr>",                                   desc = "Terminate" },
    { "<leader>du", "<cmd>lua require'dap'.step_out()<cr>",                                    desc = "Step Out" },
}

whichkey.add(vim.tbl_deep_extend("force", keymap, {
    mode = "n",
    buffer = nil,
    silent = true,
    noremap = true,
    nowait = false,
}))

local keymap_v = {
    { "<leader>d",  group = "DAP" },
    { "<leader>de", "<cmd>lua require'dapui'.eval()<cr>", desc = "Evaluate" },
}
whichkey.add(vim.tbl_deep_extend("force", keymap_v, {
    mode = "v",
    buffer = nil,
    silent = true,
    noremap = true,
    nowait = false,
}))


-- DAP UI

dapui.setup(
    {
        controls = {
            element = "repl",
            enabled = true,
            icons = {
                disconnect = "",
                pause = "",
                play = "",
                run_last = "",
                step_back = "",
                step_into = "",
                step_out = "",
                step_over = "",
                terminate = ""
            }
        },
        element_mappings = {},
        expand_lines = true,
        floating = {
            border = "single",
            mappings = {
                close = { "q", "<Esc>" }
            }
        },
        force_buffers = true,
        icons = {
            collapsed = "",
            current_frame = "",
            expanded = ""
        },
        layouts = { {
            elements = { {
                id = "scopes",
                size = 0.25
            }, {
                id = "breakpoints",
                size = 0.25
            }, {
                id = "stacks",
                size = 0.25
            }, {
                id = "watches",
                size = 0.25
            } },
            position = "left",
            size = 40
        }, {
            elements = { {
                id = "console",
                size = 0.8
            }, {
                id = "repl",
                size = 0.2
            } },
            position = "bottom",
            size = 5
        } },
        mappings = {
            edit = "e",
            expand = { "<CR>", "<2-LeftMouse>" },
            open = "o",
            remove = "d",
            repl = "r",
            toggle = "t"
        },
        render = {
            indent = 1,
            max_value_lines = 100
        }
    }
)

-- dap

dap.defaults.fallback.switchbuf = "usevisible,uselast"

dap.listeners.after.event_initialized["dapui_config"] = function()
    vim.cmd.tabnew()
    dapui.open({ reset = true })
end
dap.listeners.before.event_terminated["dapui_config"] = function()
    dapui.close({ reset = true })
end
dap.listeners.before.event_exited["dapui_config"] = function()
    dapui.close({ reset = true })
    vim.cmd.tabclose()
end

-- dap-virtual-text

require("nvim-dap-virtual-text").setup {
    enabled = true,                     -- enable this plugin (the default)
    enabled_commands = true,            -- create commands DapVirtualTextEnable, DapVirtualTextDisable, DapVirtualTextToggle, (DapVirtualTextForceRefresh for refreshing when debug adapter did not notify its termination)
    highlight_changed_variables = true, -- highlight changed values with NvimDapVirtualTextChanged, else always NvimDapVirtualText
    highlight_new_as_changed = false,   -- highlight new variables in the same way as changed variables (if highlight_changed_variables)
    show_stop_reason = true,            -- show stop reason when stopped for exceptions
    commented = false,                  -- prefix virtual text with comment string
    only_first_definition = true,       -- only show virtual text at first definition (if there are multiple)
    all_references = false,             -- show virtual text on all all references of the variable (not only definitions)
    clear_on_continue = false,          -- clear virtual text on "continue" (might cause flickering when stepping)
    --- A callback that determines how a variable is displayed or whether it should be omitted
    --- @param variable Variable https://microsoft.github.io/debug-adapter-protocol/specification#Types_Variable
    --- @param buf number
    --- @param stackframe dap.StackFrame https://microsoft.github.io/debug-adapter-protocol/specification#Types_StackFrame
    --- @param node userdata tree-sitter node identified as variable definition of reference (see `:h tsnode`)
    --- @param options nvim_dap_virtual_text_options Current options for nvim-dap-virtual-text
    --- @return string|nil A text how the virtual text should be displayed or nil, if this variable shouldn't be displayed
    display_callback = function(variable, buf, stackframe, node, options)
        -- by default, strip out new line characters
        if options.virt_text_pos == 'inline' then
            return ' = ' .. variable.value:gsub("%s+", " ")
        else
            return variable.name .. ' = ' .. variable.value:gsub("%s+", " ")
        end
    end,
    -- position of virtual text, see `:h nvim_buf_set_extmark()`, default tries to inline the virtual text. Use 'eol' to set to end of line
    virt_text_pos = vim.fn.has 'nvim-0.10' == 1 and 'inline' or 'eol',

    -- experimental features:
    all_frames = false,     -- show virtual text for all stack frames not only current. Only works for debugpy on my machine.
    virt_lines = false,     -- show virtual lines instead of virtual text (will flicker!)
    virt_text_win_col = nil -- position the virtual text at a fixed window column (starting from the first text column) ,
    -- e.g. 80 to position at column 80, see `:h nvim_buf_set_extmark()`
}
