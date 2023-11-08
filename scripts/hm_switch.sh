#!/bin/bash

export NIXPKGS_ALLOW_UNFREE=1
export NIXPKGS_ALLOW_INSECURE=1


home-manager switch --show-trace

# First install
# command -v zsh | sudo tee -a /etc/shells
# sudo chsh -s $(which zsh) $USER
