# Overview

These are my dotfiles. I generally keep these in `~/dotfiles` and then symlink
things into place.

# Usage

Clone the repo to your home directory (i.e. `~/dotfiles`).

`cd` into your home directory.

Type these commands. I purposely don't put them in a script, forcing me to
think about the setup at least a tiny bit on each new machine.

```shell
# tmux
ln -s ./dotfiles/tmux.conf ./.tmux.conf

# eg
ln -s ./dotfiles/eg/egrc ./.egrc

# readline
ln -s ./dotfiles/inputrc ./.inputrc

# git
ln -s ./dotfiles/gitignore_global ./.gitignore_global
ln -s ./dotfiles/gitconfig ./.gitconfig

# tig
ln -s ./dotfiles/tigrc ./.tigrc

# mighty vim
ln -s ./dotfiles/vim/ ./.vim
ln -s ./.vim/vimrc ./.vimrc

# bash
# (I use zsh, with instructions below, but I'm keeping this in the active
# section as I sometimes still have to use it when zsh isn't available. mac
# seems to default to bash_profile, while conventionally (and currently on my
# mbair if starting from the command line) it seems to prefer .bashrc. I don't
# use this enough to know if this has changed of late, so for now I'm just
# going to link both.
ln -s ./dotfiles/bash_profile_mbAir ./.bash_profile
ln -s ./dotfiles/bash_profile_mbAir ./.bashrc

```

And on linux only:

```shell
ln -s ./dotfiles/config/rofi ./.config/rofi

ln -s ./dotfiles/config/i3 ./.config/i3

ln -s ./dotfiles/Xresources ./.Xresources
```

# Vim

I manage my vim plugins with [vim-plug](https://github.com/junegunn/vim-plug).

Open vim, hit enter through all the errors, and run `:PlugInstall`. Restart
vim.


# zsh

My zsh customizations are managed in my own
[prezto fork](https://github.com/srsudar/prezto). Follow the instructions in
the README in that repo.


# Git and Hg

My `.gitconfig` and `.hgrc` files contain system and me-specific info like
usernames and paths. Be aware you'll have to change these things if you try to
use these files.

==============
# Old but not Forgotten

These are things I don't use much anymore. I want to keep them around just in
case, however.

## Shell
```
# Don't use hg much anymore.
ln -s ./dotfiles/hgignore ./.hgignore
# The .hgrc file contains a username. Be warned.
ln -s ./dotfiles/hgrc ./.hgrc

# emacs
ln -s ./dotfiles/emacs.d/ ./.emacs.d 

# emacs for python. I wouldn't do any serious lifting in emacs these days, so
# I'm moving this here despite the fact that the emacs config itself I am
# keeping, as once or twice a year I use emacs.
# Despite liking them less and less, I still have at least one submodule that
# needs to be configured here.
git submodule init
git submodule update
```

