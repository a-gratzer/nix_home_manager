{ lib, config, pkgs, ... }:

let
  # DeepSeek API key from no_git/.env (not tracked in Git — loaded at runtime by ZSH)
  envFile = builtins.readFile (/home/ag/workspace/nix_home_manager + "/no_git/.env");
  deepseekApiKey = lib.removeSuffix "\n" (lib.last (lib.splitString "=" (lib.head (lib.splitString "\n" envFile))));
  claudeSettingsTemplate = builtins.readFile ./templates/claude-deepseek-settings.json;
  claudeSettings = builtins.replaceStrings [ "\"ANTHROPIC_API_KEY\": \"\"" ] [ "\"ANTHROPIC_API_KEY\": \"${deepseekApiKey}\"" ] claudeSettingsTemplate;
in
{

  # nixpkgs.overlays = [
  #   (import ./overlays.nix)
  # ];

  home = {
    username = "ag";
    homeDirectory = "/home/ag";
    stateVersion = "25.05";
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
      # htop
      btop-rocm
      jq
      yq
      wget
      zip
      unzip
      tree
      tldr
      bat
      eza # ls replacement written in Rust
      fd # find replacement written in Rust
      zsh-fzf-history-search
      protobuf_21 # Protocol Buffers
      httpie # Like curl but more user friendly
      fastfetch
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
      kubectl-cnpg
      #kubectx # kubectl context switching
      kubernetes-helm # Kubernetes package manager
      kustomize
      talosctl
      cilium-cli
      hubble
      argocd
#      argo-workflows
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
      #frida-tools
      mkcert
      cobra-cli
      rsync
      fzf
      cht-sh
      ripgrep

      go-protobuf
      ansible

      libgourou
      postgresql_17_jit
      k6
      nodejs_22


  ] ;

  programs.home-manager.enable = true;
  programs.git = (pkgs.callPackage ./apps/git.nix {}).programs.git;
  programs.neovim = (pkgs.callPackage ./apps/neovim/defaults.nix {}).programs.neovim;
  programs.zsh = (pkgs.callPackage ./apps/zsh.nix {}).programs.zsh;
  programs.tmux = (pkgs.callPackage ./apps/tmux.nix {}).programs.tmux;


  #home.file.".smbcredentials".source = ./no_git/.smbcredentials;
  home.file.".aliases".source = ./templates/.aliases;
  home.file.".ssh/config".source = ./templates/ssh/config;
  #home.file.".config/neofetch/terminal-ascii.txt".source = ./templates/neofetch/terminal-ascii.txt;
  home.file.".config/neofetch/config.conf".source = ./templates/neofetch/config.conf;
  home.file.".config/claude-deepseek-settings.json".text = claudeSettings;
  home.file.".claude/settings.json" = {
    text = claudeSettings;
    force = true;
  };

  news.display = "silent";

  xdg.enable=true;
  xdg.mime.enable=true;
  targets.genericLinux.enable=true;

}
