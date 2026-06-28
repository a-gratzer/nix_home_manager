#!/bin/bash
# Purpose 4: Show generations and optionally rollback.
#
# Usage:
#   ./scripts/list_generations.sh                  — list all generations
#   ./scripts/list_generations.sh --rollback        — rollback one generation
#   ./scripts/list_generations.sh --rollback <N>    — rollback N generations

set -euo pipefail

HM_PROFILE="/nix/var/nix/profiles/per-user/$USER/home-manager"

list_generations() {
  echo "=== home-manager generations ==="
  home-manager generations
  echo ""
  echo "To rollback: $0 --rollback [N]"
}

rollback() {
  local count="${1:-1}"

  echo "=== Current generations (before rollback) ==="
  home-manager generations
  echo ""

  echo "Rolling back $count generation(s)..."
  export NIXPKGS_ALLOW_UNFREE=1
  export NIXPKGS_ALLOW_INSECURE=1

  if [ -f "$HM_PROFILE" ]; then
    nix profile rollback --profile "$HM_PROFILE" --to "+$(( - count ))"
  else
    echo "ERROR: home-manager profile not found at $HM_PROFILE"
    echo "Try checking: ls -la /nix/var/nix/profiles/per-user/$USER/"
    exit 1
  fi

  echo ""
  echo "Rollback complete. Current generations:"
  home-manager generations
}

if [ "$#" -eq 0 ]; then
  list_generations
elif [ "$1" = "--rollback" ]; then
  if [[ "${2:-}" =~ ^[0-9]+$ ]]; then
    rollback "$2"
  elif [ -z "${2:-}" ]; then
    rollback 1
  else
    echo "Usage: $0 [--rollback [N]]"
    exit 1
  fi
else
  echo "Usage: $0 [--rollback [N]]"
  exit 1
fi