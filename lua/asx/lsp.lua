local lsp = require 'vim.lsp'
local api = vim.api
local ms = lsp.protocol.Methods
local M = {}

local get_clients = vim.lsp.get_clients

function M.mk_config(config)
    local capabilities =
        vim.tbl_deep_extend(
            "force",
            lsp.protocol.make_client_capabilities(),
            {
                workspace = {
                    didChangeWatchedFiles = {
                        dynamicRegistration = true
                    }
                },
            }
        )
    local defaults = {
        handlers = {},
        capabilities = capabilities,
        init_options = vim.empty_dict(),
        settings = vim.empty_dict(),
    }

    return vim.tbl_deep_extend("force", defaults, config or {})
end

function M.setup()
    local float_opts = { border = 'single'  } --- @type  vim.lsp.buf.hover.Opts
    vim.lsp.handlers['textDocument/hover'] = vim.lsp.buf.hover(float_opts)
    vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.buf.signature_help(float_opts)

    local lsp_group = api.nvim_create_augroup('lsp_augroup', {})

    local servers = {
        { 'html',                                                                       require('asx.lspconfigs.html') },
        --{ 'htmldjango', { 'vscode-html-language-server', '--stdio' } },
        { 'json',                                                                       { 'vscode-json-language-server', '--stdio' } },
        { 'css',                                                                        { 'vscode-css-language-server', '--stdio' } },
        { 'scss',                                                                       { 'vscode-css-language-server', '--stdio' } },
        --{ 'c',          'clangd',                                    { '.git' } },
        --{ 'cpp',        'clangd',                                    { '.git' } },
        --{ 'sh',         { 'bash-language-server', 'start' } },
        { 'rust',                                                                       require('asx.lspconfigs.rust'),              { 'Cargo.toml', '.git' } },
        --{ 'tex',        'texlab',                                    { '.git' } },
        --{ 'zig',        'zls',                                       { 'build.zig', '.git' } },

        { 'python',                                                                     require('asx.lspconfigs.python'),            { ".git", "package.json" } },
        --{ 'lua',                                                                        require('asx.lspconfigs.lua'),               { ".git", "package.json" } },
        { 'javascript',                                                                 { 'typescript-language-server', '--stdio' }, { ".git", "package.json" } },
        { 'typescript',                                                                 { 'typescript-language-server', '--stdio' }, { ".git", "package.json" } },
        { { "typescript", "html", "typescriptreact", "typescript.tsx", "htmlangular" }, require('asx.lspconfigs.angular'),           { 'project.json', '.git' }, },
    }
    --for _, server in pairs(servers) do
    --api.nvim_create_autocmd('FileType', {
    --pattern = server[1],
    --group = lsp_group,
    --callback = function(args)
    --local custom_cfg = type(server[2]) == "function" and server[2](args, server[3]) or
    --{ cmd = server[2] }
    --custom_cfg.name = custom_cfg.name == nil and server[1] or custom_cfg.name
    ----local cmd = server[2]
    ----
    --local config = M.mk_config(custom_cfg)
    ----local config = M.mk_config({
    ----name = type(cmd) == "table" and cmd[1] or cmd,
    ----cmd = type(cmd) == "table" and cmd or { cmd },
    ----})
    --local markers = server[3]
    --if markers then
    --config.root_dir = vim.fs.root(args.file, markers)
    --end
    ----print(vim.inspect(config))
    --vim.lsp.start(config)
    --end,
    --})
    --end
    --




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
            local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
            local opts = { buffer = args.buf }

            keymap.set("n", "gr", function() vim.lsp.buf.references({ includeDeclaration = false }) end)
            keymap.set("n", "gd", vim.lsp.buf.definition)
            keymap.set("n", "gD", vim.lsp.buf.declaration)
            keymap.set("n", "gi", vim.lsp.buf.implementation)
            keymap.set("n", "K", vim.lsp.buf.hover, opts)
            keymap.set("i", "<C-h>", vim.lsp.buf.signature_help)
            keymap.set("n", "<leader>vws", vim.lsp.buf.workspace_symbol, opts)
            keymap.set("n", "<leader>vd", vim.diagnostic.open_float, opts)
            keymap.set("n", "[d", vim.diagnostic.get_next, opts)
            keymap.set("n", "]d", vim.diagnostic.get_prev, opts)
            keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, opts)
            keymap.set("n", "<leader>f", vim.cmd.RelativeCodeFormat, opts)
            keymap.set({ "n", "v" }, "<leader>vca", vim.lsp.buf.code_action, opts)
            keymap.set({ "n", "v" }, "<leader>vrf",
                "<Cmd>lua vim.lsp.buf.code_action { context = { only = {'refactor'} }}<CR>", opts)
            keymap.set("n", "<leader>vrn", "<Cmd>lua vim.lsp.buf.rename(vim.fn.input('New Name: '))<CR>", opts)
            keymap.set("i", "<c-n>", vim.lsp.completion.get, opts)
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

                keymap.set("n", "<leader>ca", autorefresh, { buffer = bufnr })
                keymap.set("n", "<leader>cc", clear, { buffer = bufnr })
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

            vim.lsp.completion.enable(false, client.id, args.buf, { autotrigger = true })

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
            --pcall(require('lsp_compl').detach, args.data.client_id, args.buf)
        end,
    })

    api.nvim_create_user_command(
        "RelativeCodeFormat",
        function()
            vim.lsp.buf.format({ async = true })
        end,
        {}
    )

    local cmp = require('cmp')
    local cmp_select = { behavior = cmp.SelectBehavior.Select }
    cmp.setup({
        mapping = cmp.mapping.preset.insert({
            ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
            ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
            ['<C-y>'] = cmp.mapping.confirm({ select = true }),
            ['<C-Space>'] = cmp.mapping.complete(),
            ['<Tab>'] = nil,
            ['<S-Tab>'] = nil,
        }),
        sources = {
            { name = 'nvim_lsp' },
            { name = 'supermaven' }
        }
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

function M.enable()
    local mason = require("mason")
    mason.setup()
    vim.lsp.enable({ 'lua_ls', 'lemminx', 'gopls', 'golangci_lint_ls' })
    M.setup()
end

return M
