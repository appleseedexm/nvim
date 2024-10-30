local lsp = require 'vim.lsp'
local api = vim.api
local ms = lsp.protocol.Methods
local M = {}

---@diagnostic disable-next-line: deprecated
local get_clients = vim.lsp.get_clients or vim.lsp.get_active_clients


function M.mk_config(config)
    --local lsp_compl = require('lsp_compl')
    local capabilities = vim.tbl_deep_extend(
        "force",
        lsp.protocol.make_client_capabilities(),
        --lsp_compl.capabilities(),
        {
            workspace = {
                didChangeWatchedFiles = {
                    dynamicRegistration = true
                }
            },
        }
    )
    local defaults = {
        flags = {
            debounce_text_changes = 80,
        },
        handlers = {},
        capabilities = capabilities,
        on_attach = function(client, bufnr)
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
            if vim.lsp.completion then
                vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = true })
            else
                --lsp_compl.attach(client, bufnr)
            end
        end,
        init_options = vim.empty_dict(),
        settings = vim.empty_dict(),
    }
    if config then
        return vim.tbl_deep_extend("force", defaults, config)
    else
        return defaults
    end
end

function M.setup()
    vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, { border = 'single' })
    vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = 'single' })

    local function get_root_dir(file)

    end
    local servers = {
        { 'html',                                                                       require('asx.lspconfigs.html') },
        --{ 'htmldjango', { 'vscode-html-language-server', '--stdio' } },
        --{ 'json',       { 'vscode-json-language-server', '--stdio' } },
        --{ 'css',        { 'vscode-css-language-server', '--stdio' } },
        --{ 'c',          'clangd',                                    { '.git' } },
        --{ 'cpp',        'clangd',                                    { '.git' } },
        --{ 'sh',         { 'bash-language-server', 'start' } },
        { 'rust',                                                                       require('asx.lspconfigs.rust'),    { 'Cargo.toml', '.git' } },
        --{ 'tex',        'texlab',                                    { '.git' } },
        --{ 'zig',        'zls',                                       { 'build.zig', '.git' } },
        --{ 'javascript', { 'typescript-language-server', '--stdio' }, { ".git", "package.json" } },
        --{ 'typescript', { 'typescript-language-server', '--stdio' }, { ".git", "package.json" } },
        { { "typescript", "html", "typescriptreact", "typescript.tsx", "htmlangular" }, require('asx.lspconfigs.angular'), { 'project.json', '.git' }, },
    }
    local lsp_group = api.nvim_create_augroup('lsp', {})
    for _, server in pairs(servers) do
        api.nvim_create_autocmd('FileType', {
            pattern = server[1],
            group = lsp_group,
            callback = function(args)
                local cmd = type(server[2]) == "function" and server[2](args, server[3]) or server[2]
                local custom_cfg = type(server[2]) == "function" and server[2](args, server[3]) or server[2]
                --local cmd = server[2]
                --
                local config = M.mk_config(custom_cfg)
                --local config = M.mk_config({
                --name = type(cmd) == "table" and cmd[1] or cmd,
                --cmd = type(cmd) == "table" and cmd or { cmd },
                --})
                local markers = server[3]
                if markers then
                    config.root_dir = vim.fs.root(args.file, markers)
                end
                --print(vim.inspect(config))
                print(vim.inspect(config.root_dir))
                vim.lsp.start(config)
            end,
        })
    end
    if vim.fn.exists('##LspAttach') ~= 1 then
        return
    end
    local keymap = vim.keymap
    if vim.fn.exists("##LspProgress") == 1 then
        local timer = vim.loop.new_timer()
        api.nvim_create_autocmd("LspProgress", {
            group = lsp_group,
            callback = function()
                if api.nvim_get_mode().mode == "n" then
                    vim.cmd.redrawstatus()
                end
                if timer then
                    timer:stop()
                    timer:start(500, 0, vim.schedule_wrap(function()
                        timer:stop()
                        vim.cmd.redrawstatus()
                    end))
                end
            end
        })
    end
    api.nvim_create_autocmd('LspAttach', {
        group = lsp_group,
        callback = function(args)
            -- array of mappings to setup; {<capability>, <mode>, <lhs>, <rhs>}
            local key_mappings = {
                { "referencesProvider", "n", "gr",
                    function()
                        vim.lsp.buf.references({ includeDeclaration = false })
                    end
                },
                { "implementationProvider", "n", "gd",          vim.lsp.buf.definition },
                { "implementationProvider", "n", "gD",          vim.lsp.buf.declaration },
                { "implementationProvider", "n", "gi",          vim.lsp.buf.implementation },
                { "signatureHelpProvider",  "i", "<C-h>",       vim.lsp.buf.signature_help },
                { "codeLensProvider",       "n", "<leader>clr", function() vim.lsp.codelens.refresh({ bufnr = 0 }) end },
                { "codeLensProvider",       "n", "<leader>cle", vim.lsp.codelens.run },
                { "codeLensProvider", "n", "<leader>cla",
                    function()
                        vim.lsp.codelens.refresh({ bufnr = 0 })
                        local bufnr = api.nvim_get_current_buf()
                        api.nvim_create_autocmd({ 'InsertLeave', 'CursorHold' }, {
                            group = api.nvim_create_augroup(string.format('lsp-codelens-%s', bufnr), {}),
                            buffer = bufnr,
                            callback = function()
                                vim.lsp.codelens.refresh({ bufnr = 0 })
                            end,
                        })
                    end
                },
                { "codeLensProvider", "n", "<leader>clc",
                    function()
                        local bufnr = api.nvim_get_current_buf()
                        if vim.lsp.codelens.clear then
                            vim.lsp.codelens.clear(nil, bufnr)
                        end
                        local group = string.format('lsp-codelens-%s', bufnr)
                        pcall(api.nvim_del_augroup_by_name, group)
                    end
                },
            }

            keymap.set({ "n", "v" }, "<leader>vca", vim.lsp.buf.code_action, { buffer = args.buf })
            keymap.set({ "n", "v" }, "<leader>vrf",
                "<Cmd>lua vim.lsp.buf.code_action { context = { only = {'refactor'} }}<CR>",
                { buffer = args.buf })
            keymap.set("n", "<leader>vrn", "<Cmd>lua vim.lsp.buf.rename(vim.fn.input('New Name: '))<CR>",
                { buffer = args.buf })
            keymap.set("i", "<c-n>", function()
                if vim.lsp.completion then
                    vim.lsp.completion.trigger()
                else
                    --require("lsp_compl").trigger_completion()
                end
            end, { buffer = args.buffer })

            local opts = { buffer = args.buf }

            -- todo impl capabilities
            vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
            vim.keymap.set("n", "<leader>vws", vim.lsp.buf.workspace_symbol, opts)
            vim.keymap.set("n", "<leader>vd", vim.diagnostic.open_float, opts)
            vim.keymap.set("n", "[d", vim.diagnostic.goto_next, opts)
            vim.keymap.set("n", "]d", vim.diagnostic.goto_prev, opts)
            vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, opts)
            vim.keymap.set("n", "<leader>f", vim.cmd.RelativeCodeFormat, opts)

            local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
            for _, mappings in pairs(key_mappings) do
                local capability, mode, lhs, rhs = unpack(mappings)
                if client.server_capabilities[capability] then
                    keymap.set(mode, lhs, rhs, { buffer = args.buf, silent = true })
                end
            end
            if client.server_capabilities.documentHighlightProvider then
                local group = api.nvim_create_augroup(string.format('lsp-%s-%s', args.buf, args.data.client_id), {})
                api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
                    group = group,
                    buffer = args.buf,
                    callback = function()
                        local params = vim.lsp.util.make_position_params(0, client.offset_encoding)
                        client.request('textDocument/documentHighlight', params, nil, args.buf)
                    end,
                })
                api.nvim_create_autocmd('CursorMoved', {
                    group = group,
                    buffer = args.buf,
                    callback = function()
                        pcall(vim.lsp.buf.clear_references)
                    end,
                })
            end
        end,
    })
    api.nvim_create_autocmd('LspDetach', {
        group = lsp_group,
        callback = function(args)
            local group = api.nvim_create_augroup(string.format('lsp-%s-%s', args.buf, args.data.client_id), {})
            pcall(api.nvim_del_augroup_by_name, group)
            --pcall(require('lsp_compl').detach, args.data.client_id, args.buf)
        end,
    })

    api.nvim_create_user_command(
        'LspStop',
        function(kwargs)
            local name = kwargs.fargs[1]
            for _, client in ipairs(get_clients({ name = name })) do
                client.stop()
            end
        end,
        {
            nargs = 1,
            complete = function()
                return vim.tbl_map(function(c) return c.name end, get_clients())
            end
        }
    )
    api.nvim_create_user_command(
        "LspRestart",
        function(kwargs)
            local name = kwargs.fargs[1]
            for _, client in ipairs(get_clients({ name = name })) do
                local bufs = lsp.get_buffers_by_client_id(client.id)
                client.stop()
                vim.wait(30000, function()
                    return lsp.get_client_by_id(client.id) == nil
                end)
                local client_id = lsp.start_client(client.config)
                if client_id then
                    for _, buf in ipairs(bufs) do
                        lsp.buf_attach_client(buf, client_id)
                    end
                end
            end
        end,
        {
            nargs = "?",
            complete = function()
                return vim.tbl_map(function(c) return c.name end, get_clients())
            end
        }
    )
    api.nvim_create_user_command(
        "RelativeCodeFormat",
        function()
            print("runn default")
            vim.lsp.buf.format({ async = true })
        end,
        {}
    )

    local cmp = require('cmp')
    local lsp_zero = require('lsp-zero')
    local cmp_format = lsp_zero.cmp_format()
    local cmp_select = { behavior = cmp.SelectBehavior.Select }

    -- log cmp
    cmp.setup({
        formatting = cmp_format,
        mapping = cmp.mapping.preset.insert({
            ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
            ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
            ['<C-y>'] = cmp.mapping.confirm({ select = true }),
            ['<C-Space>'] = cmp.mapping.complete(),
            ['<Tab>'] = nil,
            ['<S-Tab>'] = nil,
        }),
        sources = {
            { name = 'nvim_lsp'},
            { name = 'supermaven' }
        }
    })

    --cmp_mappings['<Tab>'] = nil
    --cmp_mappings['<S-Tab>'] = nil

    --lsp.setup_nvim_cmp({
    --mapping = cmp_mappings
    --})

    lsp_zero.set_preferences({
        suggest_lsp_servers = true,
    })

    lsp_zero.set_sign_icons({
        error = 'E',
        warn = 'W',
        hint = 'H',
        info = 'I'
    })

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

return M
