{ lib, config, pkgs, ... }:

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
  home.sessionVariables = {
      EDITOR = "nvim";
      TERMINAL = "zsh";
    };

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
      exa # ls replacement written in Rust
      fd # find replacement written in Rust
      zsh-history
      protobuf # Protocol Buffers
      httpie # Like curl but more user friendly
    # ######################
    # GIT
      git
      meld
    # ######################
    # DEV
      gnumake
      maven
      tmuxinator
      #byobu

    # ######################
    # OPS
    ansible # Deployment done right
    # ######################
    # CLOUD
    kubectl # Kubernetes CLI tool
    kubectx # kubectl context switching
    kubernetes-helm # Kubernetes package manager
    kustomize
    # minikube # Local Kubernetes
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
#        slack
        discord
      # EDITORS
        sublime4
      # DB
        #robo3t
      # REST
        #postman
        #insomnia
  ];

  programs.home-manager.enable = true;
  programs.git = (pkgs.callPackage ./apps/git.nix {}).programs.git;
  programs.tmux = (pkgs.callPackage ./apps/tmux.nix {}).programs.tmux;
  programs.direnv = (pkgs.callPackage ./apps/direnv.nix {}).programs.direnv;
  programs.neovim = (pkgs.callPackage ./apps/neovim/defaults.nix {}).programs.neovim;
  #programs.zsh = (pkgs.callPackage ./apps/zsh.nix {}).programs.zsh;

  home.file.".tmuxinator.yml".source = ./templates/tmuxinator/default.yml;
  home.file.".aliases".source = ./templates/.aliases;

  news.display = "silent";

  xdg.enable=true;
  xdg.mime.enable=true;
  targets.genericLinux.enable=true;
  xdg.mimeApps.defaultApplications = { "text/html" = ["chromium-browser.desktop"];};
}
