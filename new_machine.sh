#!/usr/bin/env bash
set -euo pipefail

# Repos: name, target path, clone URL
declare -A REPOS=(
  [dotfiles]="$HOME/dotfiles|git@github.com:srsudar/dotfiles.git"
  [zprezto]="$HOME/.zprezto|git@github.com:srsudar/prezto-private.git"
  [nvim-config]="$HOME/.config/nvim|git@github.com:srsudar/nvim-config.git"
)

info()  { printf '  \033[1;34m→\033[0m %s\n' "$*"; }
skip()  { printf '  \033[0;33m⊘\033[0m %s (already exists)\n' "$*"; }
ok()    { printf '  \033[0;32m✓\033[0m %s\n' "$*"; }
err()   { printf '  \033[0;31m✗\033[0m %s\n' "$*" >&2; }

# ── 1. Clone repos if missing ───────────────────────────────────────
echo "Checking repos..."
for name in "${!REPOS[@]}"; do
  IFS='|' read -r path url <<< "${REPOS[$name]}"
  if [ -d "$path/.git" ]; then
    skip "$name already cloned at $path"
  else
    info "Cloning $name → $path"
    git clone "$url" "$path"
    ok "$name cloned"
  fi
done

# ── 2. Helper: make a symlink ────────────────────────────────────────
make_link() {
  local target="$1" link="$2"
  local link_dir
  link_dir="$(dirname "$link")"

  if [ -L "$link" ]; then
    local existing
    existing="$(readlink "$link")"
    if [ "$existing" = "$target" ]; then
      skip "$link"
      return
    else
      err "$link exists but points to $existing (expected $target)"
      return
    fi
  elif [ -e "$link" ]; then
    err "$link exists and is not a symlink — skipping"
    return
  fi

  mkdir -p "$link_dir"
  ln -s "$target" "$link"
  ok "$link → $target"
}

# ── 3. dotfiles symlinks ─────────────────────────────────────────────
echo ""
echo "Linking dotfiles..."

# git
make_link "$HOME/dotfiles/gitconfig"        "$HOME/.gitconfig"
make_link "$HOME/dotfiles/gitignore_global" "$HOME/.gitignore_global"

# tmux
make_link "$HOME/dotfiles/tmux.conf"        "$HOME/.tmux.conf"

# eg
make_link "$HOME/dotfiles/eg/egrc"          "$HOME/.egrc"

# readline
make_link "$HOME/dotfiles/inputrc"          "$HOME/.inputrc"

# tig
make_link "$HOME/dotfiles/tigrc"            "$HOME/.tigrc"

# ripgrep
make_link "$HOME/dotfiles/ripgreprc"        "$HOME/.ripgreprc"

# vim
make_link "$HOME/dotfiles/vim"              "$HOME/.vim"
make_link "$HOME/.vim/vimrc"                "$HOME/.vimrc"
make_link "$HOME/dotfiles/vim/ideavimrc"    "$HOME/.ideavimrc"

# ghostty
make_link "$HOME/dotfiles/ghostty/config"   "$HOME/.config/ghostty/config"

# bash
make_link "$HOME/dotfiles/bash_profile_mbAir" "$HOME/.bash_profile"
make_link "$HOME/dotfiles/bash_profile_mbAir" "$HOME/.bashrc"

# ── 4. zprezto symlinks ──────────────────────────────────────────────
echo ""
echo "Linking zprezto runcoms..."

for rcfile in zlogin zlogout zpreztorc zprofile zshenv zshrc; do
  make_link "$HOME/.zprezto/runcoms/$rcfile" "$HOME/.${rcfile}"
done

echo ""
echo "Done."
