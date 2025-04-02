# nvim config

## Plugins

I use [vim-plug](https://github.com/junegunn/vim-plug) to manage plugins.

## Dependencies

- fzf (telescope)
- ripgrep (telescope)
- git-delta (telescope)
- fd (telescope)
- gcc (treesitter)
- go (gitlab)
- universal-ctags (tagbar)
- nerd-fonts (lualine)
- lazygit (lazygit)

## Soft Dependencies

These will throw an error if not found, but probably only need configuratiom or plugin removal
- JDKs (jdtls)
- Obsidian (obsidian)
- luarocks (luaformatter)
- inotify-tools (improved file-watcher backend)

## LSPs

- Rust
- Java
- Go
- JS / TS
- Python
- HTML / CSS
- JSON
- Lua
- Angular

## Manual Steps

`telescope-fzf-native.nvim` needs a manual `make` in the plugin folder (not sure if a setup bug or a plugin bug)

## TODO

- [ ] Replace either glaive or conform, doesnt need both
- [ ] Refactor all LSPs into a single setup
