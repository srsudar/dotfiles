#!/usr/bin/env bash
set -euo pipefail

info()  { printf '  \033[1;34m→\033[0m %s\n' "$*"; }
skip()  { printf '  \033[0;33m⊘\033[0m %s (already exists)\n' "$*"; }
ok()    { printf '  \033[0;32m✓\033[0m %s\n' "$*"; }
err()   { printf '  \033[0;31m✗\033[0m %s\n' "$*" >&2; }

clone_if_missing() {
  local url="$1" path="$2" name="$3"
  if [ -d "$path/.git" ]; then
    skip "$name already cloned at $path"
  else
    info "Cloning $name → $path"
    git clone "$url" "$path"
    ok "$name cloned"
  fi
}

make_link() {
  local target="$1" link="$2"
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
  mkdir -p "$(dirname "$link")"
  ln -s "$target" "$link"
  ok "$link → $target"
}

# ── 0. Manual prerequisites ─────────────────────────────────────────
echo "Checking prerequisites..."

MISSING=()

if ! command -v brew &>/dev/null; then
  MISSING+=("  Homebrew: https://brew.sh")
fi

if ! command -v rustup &>/dev/null; then
  MISSING+=("  Rust:     https://rustup.rs")
fi

if ! command -v nvm &>/dev/null && [ ! -d "$HOME/.nvm" ]; then
  MISSING+=("  nvm:      https://github.com/nvm-sh/nvm#installing-and-updating")
fi

if [ ${#MISSING[@]} -gt 0 ]; then
  err "Missing tools that require manual installation:"
  for line in "${MISSING[@]}"; do
    echo "$line"
  done
  echo ""
  err "Install these first, then re-run this script."
  exit 1
fi

ok "All prerequisites found"

# ── 1. Core repos ───────────────────────────────────────────────────
echo ""
echo "Checking repos..."
clone_if_missing "git@github.com:srsudar/dotfiles.git"       "$HOME/dotfiles"      "dotfiles"
clone_if_missing "git@github.com:srsudar/prezto-private.git"  "$HOME/.zprezto"      "zprezto"
clone_if_missing "git@github.com:srsudar/nvim-config.git"     "$HOME/.config/nvim"  "nvim-config"

# ── 2. Zsh plugins (referenced in zshrc) ────────────────────────────
echo ""
echo "Checking zsh plugins..."
mkdir -p "$HOME/.zsh"
clone_if_missing "https://github.com/zdharma/fast-syntax-highlighting"  "$HOME/.zsh/fast-syntax-highlighting"  "fast-syntax-highlighting"
clone_if_missing "https://github.com/zsh-users/zsh-autosuggestions.git" "$HOME/.zsh/zsh-autosuggestions"        "zsh-autosuggestions"
clone_if_missing "https://github.com/Aloxaf/fzf-tab"                   "$HOME/.zsh/fzf-tab"                    "fzf-tab"
clone_if_missing "https://github.com/srsudar/fzf-complete-flags"        "$HOME/.zsh/fzf-complete-flags"         "fzf-complete-flags"

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

# ── 4. zprezto symlinks (from prezto README) ─────────────────────────
echo ""
echo "Linking zprezto runcoms..."

zsh -c '
  setopt EXTENDED_GLOB
  for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
    ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}" 2>/dev/null && \
      printf "  \033[0;32m✓\033[0m %s → %s\n" "${ZDOTDIR:-$HOME}/.${rcfile:t}" "$rcfile" || \
      printf "  \033[0;33m⊘\033[0m %s (already exists)\n" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
  done
'

# ── 5. Homebrew packages (macOS only) ────────────────────────────────
if [ "$(uname -s)" = "Darwin" ]; then
  echo ""
  echo "Checking Homebrew packages..."

  BREW_PACKAGES=(
    atuin
    bat
    eg-examples
    ffmpeg
    go
    jq
    k9s
    livekit-cli
    bob
    sqlite
    tig
    tmux
    uv
    zig
  )

  for pkg in "${BREW_PACKAGES[@]}"; do
    if brew list --formula "$pkg" &>/dev/null; then
      skip "$pkg"
    else
      info "Installing $pkg"
      brew install "$pkg"
      ok "$pkg installed"
    fi
  done
fi

echo ""
echo "Done."
