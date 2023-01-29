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
      exa # ls replacement written in Rust
      fd # find replacement written in Rust
      zsh-history
      protobuf # Protocol Buffers
      httpie # Like curl but more user friendly
      neofetch
    # ######################
    # NETWORK
      wireguard-tools
    # ######################
    # GIT
      git
      meld
    # ######################
    # DEV
      gnumake
#      maven
      tmuxinator
      #byobu

    # ######################
    # OPS
    #ansible
    # ######################
    # CLOUD
    kubectl # Kubernetes CLI tool
    kubectx # kubectl context switching
    kubernetes-helm # Kubernetes package manager
    kustomize
    # minikube # Local Kubernetes
    #k9s
#    lens -> crash on startup...
    # ######################
    # 	Virtualization
      podman
      docker-compose
    # ######################
    # GUI
      # BROWSER
        google-chrome
        brave
      # CHAT
        slack
        discord
      # EDITORS
        sublime4
      # DB
        robo3t
      # REST
        postman
        insomnia
        # screenshot-tool
        flameshot
        # screen-recorder
        kazam
        # VNC
        remmina
  ] ;

  programs.home-manager.enable = true;
  programs.git = (pkgs.callPackage ./apps/git.nix {}).programs.git;
#  programs.direnv = (pkgs.callPackage ./apps/direnv.nix {}).programs.direnv;
  programs.neovim = (pkgs.callPackage ./apps/neovim/defaults.nix {}).programs.neovim;
  programs.zsh = (pkgs.callPackage ./apps/zsh.nix {}).programs.zsh;
  programs.tmux = (pkgs.callPackage ./apps/tmux.nix {}).programs.tmux;

  home.file.".tmuxinator.yml".source = ./templates/tmuxinator/default.yml;
  home.file.".aliases".source = ./templates/.aliases;

  news.display = "silent";

  xdg.enable=true;
  xdg.mime.enable=true;
  targets.genericLinux.enable=true;
  xdg.mimeApps.defaultApplications = { "text/html" = [
    "chromium-browser.desktop"
  ];};
}
