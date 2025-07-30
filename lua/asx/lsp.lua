local lsp = require 'vim.lsp'
local cmp = require 'mini.completion'
local api = vim.api
local ms = lsp.protocol.Methods
local M = {}

local get_clients = vim.lsp.get_clients

local function setup_completion()
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
            process_items = nil,

            -- A function which takes a snippet as string and inserts it at cursor.
            -- Default: `default_snippet_insert` which tries to use 'mini.snippets'
            -- and falls back to `vim.snippet.expand` (on Neovim>=0.10).
            snippet_insert = nil,
        },

        -- Fallback action as function/string. Executed in Insert mode.
        -- To use built-in completion (`:h ins-completion`), set its mapping as
        -- string. Example: set '<C-x><C-l>' for 'whole lines' completion.
        fallback_action = '<C-X><C-O>',

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
                for _, char in ipairs({ "a", "e", "i", "o", "u" }) do
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

local function mk_tag_item(name, range, uri)
    local start = range.start
    return {
        name = name,
        filename = vim.uri_to_fname(uri),
        cmd = string.format(
            'call cursor(%d, %d)', start.line + 1, start.character + 1
        )
    }
end

function M.symbol_tagfunc(pattern, flags)
    if not (flags == 'c' or flags == '' or flags == 'i') then
        return vim.NIL
    end
    local clients = get_clients({ method = ms.workspace_symbol })
    local num_clients = vim.tbl_count(clients)
    local results = {}
    local bufnr = api.nvim_get_current_buf()
    for _, client in pairs(clients) do
        client.request(ms.workspace_symbol, { query = pattern }, function(_, method_or_result, result_or_ctx)
            local result = type(method_or_result) == 'string' and result_or_ctx or method_or_result
            for _, symbol in pairs(result or {}) do
                local loc = symbol.location
                local item = mk_tag_item(symbol.name, loc.range, loc.uri)
                item.kind = (lsp.protocol.SymbolKind[symbol.kind] or 'Unknown')[1]
                table.insert(results, item)
            end
            num_clients = num_clients - 1
        end, bufnr)
    end
    vim.wait(1500, function() return num_clients == 0 end)
    return results
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
        'angular_ls',
        'css_ls',
        'golangci_lint_ls',
        'gopls',
        'html_ls',
        'json_ls',
        'lemminx',
        'lua_ls',
        'marksman',
        'python_ls',
        'rust-analyzer',
        'typescript_ls',
        'zls'
    })

    setup_completion()

    setup()
end

return M
