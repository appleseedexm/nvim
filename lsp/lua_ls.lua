return require('asx.lsp').mk_config({
    cmd = { 'lua-language-server' },
    root_markers = { '.git', '.luarc.json' },
    filetypes = { 'lua' },
    settings = {
        single_file_support = true,
        Lua = {
            diagnostics = {
                globals = { "vim" }
            },
            runtime = {
                path = {
                    "./?.lua",
                    "/usr/share/luajit-2.1/?.lua",
                    "/usr/local/share/lua/5.1/?.lua",
                    "/usr/local/share/lua/5.1/?/init.lua",
                    "/usr/share/lua/5.1/?.lua",
                    "/usr/share/lua/5.1/?/init.lua",
                    "lua/?.lua",
                    "lua/?/init.lua"
                },
                version = "LuaJIT"
            },
            telemetry = {
                enable = false
            },
            workspace = {
                checkThirdParty = false,
                library = { "/usr/share/nvim/runtime/lua", "/home/asx/.config/nvim/lua" }
            }
        }
    }
})
