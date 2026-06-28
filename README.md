# nix_home_manager

Home-manager configuration using Nix flakes.

## Prerequisites

- Nix 2.17+ with flakes enabled (`experimental-features = nix-command flakes`)
- This repo cloned

## Setup

```bash
# Clone the repo and symlink it
ln -s "$PWD" ~/.config/home-manager

# Or use the install script
./scripts/install_hm.sh
```

## Usage

```bash
# Apply changes
home-manager switch --flake ~/workspace/nix_home_manager

# Or use the helper script
./scripts/hm_switch.sh

# Update nixpkgs & home-manager
nix flake update ~/workspace/nix_home_manager
home-manager switch --flake ~/workspace/nix_home_manager

# List generations
home-manager generations

# Clean up old generations
./scripts/cleanup.sh
```

## Claude Code alias

Typing `claude` runs:
```bash
claude --bare --settings ~/.config/claude-deepseek-settings.json --model sonnet
```
