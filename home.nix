{ config, pkgs, ... }:

let
  config = import ./config.nix;

in
{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "ag";
  home.homeDirectory = "/home/ag";
  home.stateVersion = "22.05";

  # nixpkgs.overlays = [
  #   (import ./overlays.nix)
  # ];

  home.packages = with pkgs; [
    # ######################
    # UTILS
      htop
      jq
      wget
      zip
      unzip
      tree
      tldr
      bat
    # ######################
    # GIT
      git
      meld
    # ######################
    # DEV
      maven
      tmux
     	tmuxinator
    # ######################
    # 	Virtualization
      podman
      docker-compose
    # ######################
    # GUI
      # BROWSER
        google-chrome
      # CHAT
        slack
        discord
      # EDITORS
        sublime4
  ];

  programs.home-manager.enable = true;
  programs.git = (pkgs.callPackage ./apps/git.nix {}).programs.git;
  programs.tmux = (pkgs.callPackage ./apps/tmux/default.nix {}).programs.tmux;

  news.display = "silent";

  xdg.enable=true;
  xdg.mime.enable=true;
  targets.genericLinux.enable=true;
  xdg.mimeApps.defaultApplications = { "text/html" = ["chromium-browser.desktop"];};
}
