#!/bin/bash

# https://nix.dev/tutorials/install-nix
sh <(curl -L https://nixos.org/nix/install) --daemon

nix --version


# channels
# https://nixos.wiki/wiki/Nix_channels
nix-channel --add https://nixos.org/channels/nixpkgs-unstable unstable
nix-channel --list
