-- lua, default settings
require("better_escape").setup {
    timeout = vim.o.timeoutlen, -- after `timeout` passes, you can press the escape key and the plugin will ignore it
    default_mappings = true,    -- setting this to false removes all the default mappings
    mappings = {
        -- i for insert
        i = {
            j = {
                -- These can all also be functions
                --k = "<Esc>",
                --j = "<Esc>",
            },
            [" "] = {
                [" "] = "<Esc>",
            },
        },
        c = {
            j = {
                --k = "<C-c>",
                --j = "<C-c>",
            },
            [" "] = {
                [" "] = "<Esc>",
            },
        },
        t = {
            j = {
                --k = "<C-\\><C-n>",
            },
            [" "] = {
                [" "] = "<Esc>",
            },
        },
        v = {
            j = {
                --k = "<Esc>",
            },
            [" "] = {
                [" "] = "<Esc>",
            }
        },
        s = {
            j = {
                --k = "<Esc>",
            },
            [" "] = {
                [" "] = "<Esc>",
            }
        },
    },
}
