#!/bin/bash
# Purpose 1: Initial setup on a new computer.
# Clone the repo, then run this script to set up home-manager from scratch.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "=== nix_home_manager — Setup ==="

# Check Nix
if ! command -v nix &>/dev/null; then
  echo "ERROR: Nix is not installed."
  echo "Install it first:"
  echo "  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install"
  exit 1
fi

NIX_VERSION=$(nix --version 2>/dev/null | grep -oP '\d+\.\d+' | head -1)
echo "Nix version: $(nix --version)"

# Check flakes
if ! nix show-config --json 2>/dev/null | grep -q '"experimental-features".*flakes'; then
  echo "WARNING: flakes may not be enabled. Checking /etc/nix/nix.conf..."
  if ! grep -q 'experimental-features.*flakes' /etc/nix/nix.conf 2>/dev/null; then
    echo "ERROR: flakes are not enabled."
    echo "Add to /etc/nix/nix.conf:"
    echo "  experimental-features = nix-command flakes"
    exit 1
  fi
fi

# Check home-manager
if ! command -v home-manager &>/dev/null; then
  echo "home-manager not found — installing via nix run..."
  nix run github:nix-community/home-manager/master -- init --switch
fi

# Link repo to ~/.config/home-manager for non-flake fallback
if [ ! -L "$HOME/.config/home-manager" ]; then
  if [ -e "$HOME/.config/home-manager" ]; then
    echo "WARNING: ~/.config/home-manager exists and is not a symlink."
    echo "Backing up to ~/.config/home-manager.bak"
    mv "$HOME/.config/home-manager" "$HOME/.config/home-manager.bak"
  fi
  ln -s "$REPO_DIR" "$HOME/.config/home-manager"
  echo "Linked $REPO_DIR -> ~/.config/home-manager"
fi

# Build and activate
echo "Running: home-manager switch --flake $REPO_DIR"
export NIXPKGS_ALLOW_UNFREE=1
export NIXPKGS_ALLOW_INSECURE=1
home-manager switch --flake "$REPO_DIR" --show-trace

echo ""
echo "Done! You may need to restart your shell."
echo "Optional: sudo chsh -s \$(which zsh) \$USER"
