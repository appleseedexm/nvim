# nvim config

## Disclaimer

I dont recommend blindly using my config, but taking it as reference and creating your own.
Nobody will use neovim exactly the way I do and while I try to keep most functionality close to their original configuration, some things are highly customized. 

## Manual Installation Steps

`telescope-fzf-native.nvim` needs a manual `make` in the plugin folder (not sure if a setup bug or a plugin bug, might be obsolete by the time you're installing this). 

## Plugins

I use [vim-plug](https://github.com/junegunn/vim-plug) to manage plugins.

## Dependencies

I work with the following tools which are integrated in my config:

- tmux
- fzf 
- ripgrep 
- git-delta 
- fd 
- lazygit 
- yazi 
- bat
- tree-sitter-cli

### Neovim specific

- gcc (treesitter)
- universal-ctags (tagbar)
- nerd-fonts (lualine)
- inotify-tools (improved file-watcher backend)

### Soft Dependencies

Language-specific dependencies like `rust-analyzer`, `zig` and all that. 
If you dont use the language, throw out the config from `/lsp`.


## LSP

All language server configs are in `/lsp`.
Most tools that are invoked with neovim only are installed via `mason`.

## TODO

- [x] Replace either glaive or conform, doesnt need both
- [x] Refactor all LSPs into a single setup
