# nvim config

## Plugins

I use [vim-plug](https://github.com/junegunn/vim-plug) to manage plugins.

## Dependencies

- fzf (telescope)
- ripgrep (telescope)
- git-delta (telescope)
- gcc (treesitter)
- go (gitlab)
- universal-ctags (tagbar)
- nerd fonts (lualine)
- lazygit (lazygit)

## Soft Dependencies

These will throw an error if not found, but probably only need configuratiom or plugin removal
- JDKs (jdtls)
- Obsidian (obsidian)

## LSPs

- Rust
- Java
- Go
- JS / TS
- Angular

## Manual Steps

`telescope-fzf-native.nvim` needs a manual `make` in the plugin folder (not sure if a setup bug or a plugin bug)

## TODO

- [ ] Replace either glaive or conform, doesnt need both
- [ ] Refactor all LSPs into a single setup
