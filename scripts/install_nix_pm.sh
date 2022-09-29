#!/bin/bash

# ##########################################
# INSTALL NIX
# https://nix.dev/tutorials/install-nix
curl -L https://nixos.org/nix/install | sh --daemon
# run sh <(curl -L https://nixos.org/nix/install) --daemon

# ##########################################
# SOURCE NIX
. ~/.nix-profile/etc/profile.d/nix.sh

nix --version

# channels
# https://nixos.wiki/wiki/Nix_channels
nix-channel --add https://nixos.org/channels/nixpkgs-unstable unstable
nix-channel --list
