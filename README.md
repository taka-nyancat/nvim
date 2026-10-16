# Neovim configuration

This repository contains my Neovim configuration.

## Install

Clone with ghq:

```sh
ghq get taka-nyancat/nvim
```

Back up any existing config, then link this checkout:

```sh
mv ~/.config/nvim ~/.config/nvim.backup
ln -s "$(ghq root)/github.com/taka-nyancat/nvim" ~/.config/nvim
```

Open Neovim; lazy.nvim will bootstrap and install plugins. LSP servers and other tools may need to be installed separately. This configuration uses Mason for `pyright` and `ts_ls`; other enabled language servers should be installed with your preferred package manager.
