# dotfiles

> My dotfiles

## Overview

These are my dotfiles. I keep all my configuration files (i.e. dotfiles) in
this repo in my home directory and put the files in the correct location with
symbolic links. See [Usage] (#usage).

## Usage

These are the commands you'll have to run if you want to use these. I
purposely don't put them in a script, forcing me to think about the setup at
least a tiny bit on each new machine.

These commands assume the cwd is your home directory.

```shell
# tmux
ln -s ./dotfiles/tmux.conf ./.tmux.conf

# tmux tab completion. I manually copy this file from the one maintained
# at https://github.com/srsudar/tmux-completion
ln -s ./dotfiles/bash_profile_mbAir ./.bash_profile

# emacs
ln -s ./dotfiles/emacs.d/ ./.emacs.d 

# readline
ln -s ./dotfiles/inputrc ./.inputrc

# mighty vim
# directory
ln -s ./dotfiles/vim/ ./.vim
# vimrc. Must be run AFTER the above command, but it could just as easily
# point into the dotfiles/ directory directly.
ln -s ./.vim/vimrc ./.vimrc

# Vim depends on a number of extensions that are managed as git submodules. To
# use these, you'll also have to run the following:
git submodule init
git submodule update
```

## Vim

The way I manage my vim configuration is based on this excellent tutorial:
vimcasts.org/episodes/synchronizing-plugins-with-git-submodules-and-pathogen/

To add additional submodules, do something like the following:

Adding new submodules:
Do something like the following:

git submodule add git://github.com/tpope/vim-unimpaired.git bundle/unimpaired
