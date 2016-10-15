## Overview

These are my dotfiles. I generally keep these in `~/dotfiles` and then symlink
things into place.

## Usage

Clone the repo to your home directory (i.e. `~/dotfiles`).

`cd` into that directory.

Type these commands. I purposely don't put them in a script, forcing me to
think about the setup at least a tiny bit on each new machine.

```shell
# tmux
ln -s ./dotfiles/tmux.conf ./.tmux.conf

# readline
ln -s ./dotfiles/inputrc ./.inputrc

# git
ln -s ./dotfiles/gitignore_global ./.gitignore_global
# The .gitconfig file contains some system-specific paths as well as a
# a username. Be warned.
ln -s ./dotfiles/gitconfig_mbAir ./.gitconfig

# mighty vim
# directory
ln -s ./dotfiles/vim/ ./.vim
# vimrc. Must be run AFTER the above command, but it could just as easily
# point into the dotfiles/ directory directly.
ln -s ./.vim/vimrc ./.vimrc

```

## Vim

I manage my vim plugins with [vim-plug](https://github.com/junegunn/vim-plug).

Open vim, hit enter through all the errors, and run `:PlugInstall`. Restart
vim.


## zsh

My zsh customizations are managed in my own
[prezto fork](https://github.com/srsudar/prezto). Follow the instructions in
the README in that repo.


## Git and Hg

My `.gitconfig` and `.hgrc` files contain system and me-specific info like
usernames and paths. Be aware you'll have to change these things if you try to
use these files.

==============
## Old but not Forgotten

These are things I don't use much anymore. I want to keep them around just in
case, however.

### Shell
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

