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
    stateVersion = "23.11";
  };


  home.enableNixpkgsReleaseCheck = false;

  home.sessionVariables = {
      EDITOR = "nano";
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
      protobuf_21 # Protocol Buffers
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
      just
      gnumake
      awscli2
      # ######################
      # CLOUD
      kubectl # Kubernetes CLI tool
      kubelogin-oidc
      #kubectx # kubectl context switching
      kubernetes-helm # Kubernetes package manager
      kustomize
      talosctl
      cilium-cli
      hubble
      argocd
      argo
      k9s
      cloudflared
      # lens
      # ######################
      # Virtualization
      podman
      # docker
      docker-compose
      # ######################
      # GUI
      # CHAT
#      slack
      discord
      # EDITORS
      sublime4
      # DB
      #robo3t
      #dbeaver
      # REST
      # postman
      # insomnia
      # screenshot-tool
      flameshot
      # screen-recorder
      kazam
      # VNC
      remmina
      natscli
      nats-top
      # LDAP
      # apache-directory-studio
      p7zip
      jp2a # image to ascii
      fortune
      gnome-browser-connector
      clamav
      charles
      android-tools
      frida-tools
      mkcert
      cobra-cli
  ] ;

  programs.home-manager.enable = true;
  programs.git = (pkgs.callPackage ./apps/git.nix {}).programs.git;
  programs.neovim = (pkgs.callPackage ./apps/neovim/defaults.nix {}).programs.neovim;
  programs.zsh = (pkgs.callPackage ./apps/zsh.nix {}).programs.zsh;
  programs.tmux = (pkgs.callPackage ./apps/tmux.nix {}).programs.tmux;


  home.file.".smbcredentials".source = ./no_git/.smbcredentials;
  home.file.".aliases".source = ./templates/.aliases;
  home.file.".ssh/config".source = ./templates/ssh/config;
  home.file.".config/neofetch/terminal-ascii.txt".source = ./templates/neofetch/terminal-ascii.txt;
  home.file.".config/neofetch/config.conf".source = ./templates/neofetch/config.conf;

  news.display = "silent";

  xdg.enable=true;
  xdg.mime.enable=true;
  targets.genericLinux.enable=true;

}
