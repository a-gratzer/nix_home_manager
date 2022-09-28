{ config, pkgs, ... }:

let
  config = import ./config.nix;

in
{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "ag";
  home.homeDirectory = "/home/ag";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "22.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # nixpkgs.overlays = [
  #   (import ./overlays.nix)
  # ];

  programs.git = (pkgs.callPackage ./apps/git.nix {}).programs.git;


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
      tmux
     	tmuxinator
    # ######################
    # 	Virtualization
      docker-compose
    # ######################
    # GUI
      google-chrome
      slack
      sublime4
  ];


  news.display = "silent";

  xdg.enable=true;
  xdg.mime.enable=true;
  targets.genericLinux.enable=true;
  xdg.mimeApps.defaultApplications = { "text/html" = ["chromium-browser.desktop"];};
}
