#!/bin/bash
# Purpose 2: Update all installed software to the latest version.
# Updates the flake lockfile, then applies the update.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "=== Updating nixpkgs & home-manager to latest ==="
nix flake update "$REPO_DIR"

echo ""
echo "=== Applying updates ==="
export NIXPKGS_ALLOW_UNFREE=1
export NIXPKGS_ALLOW_INSECURE=1
home-manager switch --flake "$REPO_DIR" --show-trace

echo ""
echo "Update complete."