{ lib, config, pkgs, ... }:

let
  config = import ./config.nix;

in
{

  # nixpkgs.overlays = [
  #   (import ./overlays.nix)
  # ];

  home = {
    username = "ag";
    homeDirectory = "/home/ag";
    stateVersion = "20.09";
  };
  
  home.sessionVariables = {
      EDITOR = "nvim";
      TERMINAL = "zsh";
    };


  home.packages = with pkgs; [
    # ######################
    # UTILS
      openssl
      pwgen
      htop
      jq
      #yq
      wget
      zip
      unzip
      tree
      tldr
      bat
      eza # ls replacement written in Rust
      fd # find replacement written in Rust
      zsh-history
      protobuf # Protocol Buffers
      httpie # Like curl but more user friendly
      neofetch
      # ######################
      # NETWORK
      wireguard-tools
      # DB
      mongodb-tools
      # ######################
      # GIT
      git
      meld
      # ######################
      # DEV
      gnumake
      awscli2
      # tmuxinator
      # ######################
      # CLOUD
      kubectl # Kubernetes CLI tool
      kubectx # kubectl context switching
      kubernetes-helm # Kubernetes package manager
      kustomize
      k9s
      # lens
      # ######################
      # Virtualization
      # podman
      # docker
      docker-compose
      # ######################
      # GUI
      # CHAT
      slack
      discord
      # EDITORS
      sublime4
      # DB
      robo3t
      dbeaver
      # REST
      # postman
      insomnia
      # screenshot-tool
      flameshot
      # screen-recorder
      kazam
      # VNC
      remmina
      natscli
      nats-top
      # LDAP
      apache-directory-studio
      p7zip
      jp2a # image to ascii
      fortune
      cowsay
#      chrome-gnome-shell
      gnome-browser-connector
#      gnome-extension-manager
        # anti-vir
      clamav
  ] ;

  programs.home-manager.enable = true;
  programs.git = (pkgs.callPackage ./apps/git.nix {}).programs.git;
#  programs.direnv = (pkgs.callPackage ./apps/direnv.nix {}).programs.direnv;
  programs.neovim = (pkgs.callPackage ./apps/neovim/defaults.nix {}).programs.neovim;
  programs.zsh = (pkgs.callPackage ./apps/zsh.nix {}).programs.zsh;
  programs.tmux = (pkgs.callPackage ./apps/tmux.nix {}).programs.tmux;

  home.file.".tmuxinator.yml".source = ./templates/tmuxinator/default.yml;
  home.file.".aliases".source = ./templates/.aliases;
  home.file.".ssh/config".source = ./templates/ssh/config;
  home.file.".config/neofetch/terminal-ascii.txt".source = ./templates/neofetch/terminal-ascii.txt;

  news.display = "silent";
  xdg.enable=true;
  xdg.mime.enable=true;
  targets.genericLinux.enable=true;



}
