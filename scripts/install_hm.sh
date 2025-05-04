#!/bin/bash

export NIXPKGS_ALLOW_UNFREE=1
export NIXPKGS_ALLOW_INSECURE=1

# https://nix-community.github.io/home-manager/index.xhtml#sec-install-standalone
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --add https://github.com/nix-community/home-manager/archive/release-24.11.tar.gz home-manager
nix-channel --update

#https://nix-community.github.io/home-manager/index.html
export NIX_PATH=$HOME/.nix-defexpr/channels:/nix/var/nix/profiles/per-user/root/channels${NIX_PATH:+:$NIX_PATH}
nix-shell '<home-manager>' -A install --show-trace

# run from folder where home.nix is
# ln -s $PWD ~/.config/home-manager
