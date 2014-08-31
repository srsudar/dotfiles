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

# hg
ln -s ./dotfiles/hgignore ./.hgignore
# The .hgrc file contains a username. Be warned.
ln -s ./dotfiles/hgrc ./.hgrc

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

# Vim depends on a number of extensions that are managed as git submodules. To
# use these, you'll also have to run the following:
git submodule init
git submodule update
```

## Vim

The way I manage my vim configuration is based on this excellent tutorial:
vimcasts.org/episodes/synchronizing-plugins-with-git-submodules-and-pathogen/

To add new submodules, do something like the following. In the below command we
are pointing at the git repo for the vim-unimpaired plugin and placing it in a
directory called `bundle/unimpaired/`, where pathogen will find it.

```shell
git submodule add git://github.com/tpope/vim-unimpaired.git bundle/unimpaired
```

## Git and Hg

My `.gitconfig` and `.hgrc` files contain system and me-specific info like
usernames and paths. Be aware you'll have to change these things if you try to
use these files.

## zsh

Recently I've been messing around with `zsh`, and am well on my way to switching
for good. The main reasons are easier hg status in the prompt, colorized tab
completion output, and better overall tab completion. It's the little things.

Originally I tried [oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh),
but struggled to get the colorized output on tab completion to work, so I gave
[prezto](https://github.com/sorin-ionescu/prezto) a try. This was much easier
for me to configure, and I felt like it was more overt about its magic, which
I appreciated. Being new to `zsh`, I don't miss any potential plugins that only
exist for oh-my-zsh.

My zsh customizations are managed in my own
[prezto fork](https://github.com/srsudar/prezto). The next time I get setup on
a new machine I'll add my fork as a submodule to this project. Until then,
replicating my complete configuration will require also following the
instructions for prezto as seen in the `README` in that repo.

On that note, the contents of the `zsh/` directory here are mostly vestiges of
the old oh-my-zsh environment. They are mostly dead and will eventually be
removed or converted for prezto.
