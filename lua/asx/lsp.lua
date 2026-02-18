local lsp = require 'vim.lsp'
local cmp = require 'mini.completion'
local api = vim.api
local M = {}

local function setup_completion()
    local completionItemKind = {
        Text = 1,
        Method = 2,
        Function = 3,
        Constructor = 4,
        Field = 5,
        Variable = 6,
        Class = 7,
        Interface = 8,
        Module = 9,
        Property = 10,
        Unit = 11,
        Value = 12,
        Enum = 13,
        Keyword = 14,
        Snippet = 15,
        Color = 16,
        File = 17,
        Reference = 18,
        Folder = 19,
        EnumMember = 20,
        Constant = 21,
        Struct = 22,
        Event = 23,
        Operator = 24,
        TypeParameter = 25,
    }
    local kind_priority = vim.tbl_deep_extend('force', completionItemKind, { Text = 0, Snippet = 10, Variable = 25, })
    local opts = { filtersort = 'fuzzy', kind_priority = kind_priority }
    local process_items = function(items, base)
        local result = MiniCompletion.default_process_items(items, base, opts)
        return result or items
    end

    cmp.setup({
        -- Delay (debounce type, in ms) between certain Neovim event and action.
        -- This can be used to (virtually) disable certain automatic actions by
        -- setting very high delay time (like 10^7).
        delay = { completion = 100, info = 100, signature = 50 },

        -- Configuration for action windows:
        -- - `height` and `width` are maximum dimensions.
        -- - `border` defines border (as in `nvim_open_win()`; default "single").
        window = {
            info = { height = 25, width = 80, border = nil },
            signature = { height = 25, width = 80, border = nil },
        },

        -- Way of how module does LSP completion
        lsp_completion = {
            -- `source_func` should be one of 'completefunc' or 'omnifunc'.
            source_func = 'omnifunc',

            -- `auto_setup` should be boolean indicating if LSP completion is set up
            -- on every `BufEnter` event.
            auto_setup = false,

            -- A function which takes LSP 'textDocument/completion' response items
            -- (each with `client_id` field for item's server) and word to complete.
            -- Output should be a table of the same nature as input. Common use case
            -- is custom filter/sort. Default: `default_process_items`
            process_items = process_items,
            -- A function which takes a snippet as string and inserts it at cursor.
            -- Default: `default_snippet_insert` which tries to use 'mini.snippets'
            -- and falls back to `vim.snippet.expand` (on Neovim>=0.10).
            snippet_insert = nil,
        },

        -- Fallback action as function/string. Executed in Insert mode.
        -- To use built-in completion (`:h ins-completion`), set its mapping as
        -- string. Example: set '<C-x><C-l>' for 'whole lines' completion.
        fallback_action = '<C-N>',

        -- Module mappings. Use `''` (empty string) to disable one. Some of them
        -- might conflict with system mappings.
        mappings = {
            -- Force two-step/fallback completions
            force_twostep = '<C-M>',
            force_fallback = '',

            -- Scroll info/signature window down/up. When overriding, check for
            -- conflicts with built-in keys for popup menu (like `<C-u>`/`<C-o>`
            -- for 'completefunc'/'omnifunc' source function; or `<C-n>`/`<C-p>`).
            scroll_down = '<C-f>',
            scroll_up = '<C-b>',
        },
    })
end

function M.mk_config(config)
    local capabilities =
        vim.tbl_deep_extend(
            "force",
            lsp.protocol.make_client_capabilities(),
            cmp.get_lsp_capabilities()
        )
    local defaults = {
        handlers = {},
        capabilities = capabilities,
        init_options = vim.empty_dict(),
        settings = vim.empty_dict(),
    }

    return vim.tbl_deep_extend("force", defaults, config or {})
end

local function setup()
    local lsp_group = api.nvim_create_augroup('lsp_augroup', {})
    local keymap = vim.keymap

    local timer = vim.uv.new_timer()
    api.nvim_create_autocmd("LspProgress", {
        group = lsp_group,
        callback = function()
            if api.nvim_get_mode().mode == "n" then
                vim.cmd.redrawstatus()
            end
            if timer then
                timer:stop()
                timer:start(500, 0,
                    vim.schedule_wrap(
                        function()
                            timer:stop()
                            vim.cmd.redrawstatus()
                        end
                    )
                )
            end
        end
    })

    api.nvim_create_autocmd('LspAttach', {
        group = lsp_group,
        callback = function(args)
            vim.bo[args.buf].omnifunc = 'v:lua.MiniCompletion.completefunc_lsp'

            local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
            local opts = { buffer = args.buf }
            local float_opts = { border = 'single' } --- @type  vim.lsp.buf.hover.Opts

            keymap.set("n", "gr", function() vim.lsp.buf.references({ includeDeclaration = false }) end)
            keymap.set("n", "gd", vim.lsp.buf.definition)
            keymap.set("n", "gD", vim.lsp.buf.declaration)
            keymap.set("n", "gi", vim.lsp.buf.implementation)
            keymap.set("n", "K", function() vim.lsp.buf.hover(float_opts) end, opts)
            keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help(float_opts) end, opts)
            keymap.set("n", "<leader>vgi", vim.lsp.buf.incoming_calls)
            keymap.set("n", "<leader>vgo", vim.lsp.buf.outgoing_calls)
            keymap.set("n", "<leader>vth", vim.lsp.buf.typehierarchy)
            keymap.set("n", "<leader>vws", vim.lsp.buf.workspace_symbol, opts)
            keymap.set("n", "<leader>vd", vim.diagnostic.open_float, opts)
            keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, opts)
            keymap.set("n", "<leader>f", vim.cmd.RelativeCodeFormat, opts)
            keymap.set({ "n", "v" }, "<leader>cca", vim.lsp.buf.code_action, opts)
            keymap.set({ "n", "v" }, "<leader>crf",
                "<Cmd>lua vim.lsp.buf.code_action { context = { only = {'refactor'} }}<CR>", opts)
            keymap.set("n", "<leader>crn", vim.lsp.buf.rename, opts)
            keymap.set("n", "<leader>clr", function() vim.lsp.codelens.refresh({ bufnr = 0 }) end)
            keymap.set("n", "<leader>cle", vim.lsp.codelens.run)

            if client.server_capabilities.codeLensProvider then
                local bufnr = args.buf
                local cl_group_name = string.format("lsp-codelens-%d", bufnr)

                local function autorefresh()
                    vim.lsp.codelens.refresh({ bufnr = bufnr })
                    api.nvim_create_autocmd({ "InsertLeave", "CursorHold" }, {
                        group = api.nvim_create_augroup(cl_group_name, { clear = true }),
                        buffer = bufnr,
                        callback = function()
                            vim.lsp.codelens.refresh({ bufnr = bufnr })
                        end,
                    })
                end

                local function clear()
                    if vim.lsp.codelens.clear then
                        vim.lsp.codelens.clear(nil, bufnr)
                    end
                    pcall(api.nvim_del_augroup_by_name, cl_group_name)
                end

                keymap.set("n", "<leader>cla", autorefresh, { buffer = bufnr })
                keymap.set("n", "<leader>clc", clear, { buffer = bufnr })
            end

            if client.server_capabilities.documentHighlightProvider then
                local group = api.nvim_create_augroup(string.format("lsp-%s-%s", args.buf, args.data.client_id), {})
                api.nvim_create_autocmd("CursorHold", {
                    group = group,
                    buffer = args.buf,
                    callback = function()
                        local params = vim.lsp.util.make_position_params(0, client.offset_encoding)
                        ---@diagnostic disable-next-line: param-type-mismatch
                        client:request("textDocument/documentHighlight", params, nil, args.buf)
                    end,
                })
                api.nvim_create_autocmd("CursorMoved", {
                    group = group,
                    buffer = args.buf,
                    callback = function()
                        pcall(vim.lsp.util.buf_clear_references, args.buf)
                    end,
                })
            end

            local triggers = vim.tbl_get(client.server_capabilities, "completionProvider", "triggerCharacters")
            if triggers then
                for _, char in ipairs({ "\b" }) do
                    if not vim.tbl_contains(triggers, char) then
                        table.insert(triggers, char)
                    end
                end
                for i, t in ipairs(triggers) do
                    if t == "," then
                        triggers[i] = nil
                    end
                end
                client.server_capabilities.completionProvider.triggerCharacters = vim.iter(triggers):totable()
            end
        end,
    })
    api.nvim_create_autocmd('LspDetach', {
        group = lsp_group,
        callback = function(args)
            local group = api.nvim_create_augroup(string.format('lsp-%s-%s', args.buf, args.data.client_id), {})
            pcall(api.nvim_del_augroup_by_name, group)
        end,
    })

    api.nvim_create_user_command(
        "RelativeCodeFormat",
        function()
            require("conform").format()
        end,
        {}
    )

    vim.diagnostic.config({
        virtual_text = true
    })
end

function M.enable()
    local mason = require("mason")
    mason.setup()

    local keymap = vim.keymap
    keymap.del('n', 'grr')
    keymap.del('n', 'grn')
    keymap.del('n', 'gra')
    keymap.del('n', 'grt')
    keymap.del('n', 'gri')

    vim.lsp.enable({
        'angularls',
        'css_ls',
        'dartls',
        'golangci_lint_ls',
        'gopls',
        'html_ls',
        'json_ls',
        'lemminx',
        'lua_ls',
        'marksman',
        'python_ls',
        'rust-analyzer',
        'vtsls',
        'zls'
    })

    setup_completion()

    setup()
end

return M
