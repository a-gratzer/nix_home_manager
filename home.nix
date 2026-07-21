{ lib, config, pkgs, ... }:

let
  # DeepSeek API key from no_git/.env (not tracked in Git — loaded at runtime by ZSH)
  envFile = builtins.readFile (/home/ag/workspace/nix_home_manager + "/no_git/.env");
  deepseekApiKey = lib.removeSuffix "\n" (lib.last (lib.splitString "=" (lib.head (lib.splitString "\n" envFile))));
  claudeSettingsTemplate = builtins.readFile ./templates/claude-deepseek-settings.json;
  claudeSettings = builtins.replaceStrings [ "\"ANTHROPIC_API_KEY\": \"\"" ] [ "\"ANTHROPIC_API_KEY\": \"${deepseekApiKey}\"" ] claudeSettingsTemplate;

  agentNames = [
    "java-springboot" "golang" "ansible"
    "kubernetes" "linux-admin" "docker-optimization"
  ];

  skillNames = [
    "java-springboot" "golang" "ansible" "kubernetes"
    "linux-admin" "docker-optimization" "commit-message"
    "planning_feature" "analyse_feature"
  ];

  claudeAgents = builtins.listToAttrs (map (name: {
    name = ".claude/agents/${name}.md";
    value = { source = ./templates/claude/agents/${name}.md; };
  }) agentNames);

  claudeSkills = builtins.listToAttrs (builtins.concatMap (name: [
    { name = ".claude/skills/${name}.md";          value = { source = ./templates/claude/skills/${name}.md; }; }
    { name = ".claude/commands/skills/${name}.md"; value = { source = ./templates/claude/skills/${name}.md; }; }
  ]) skillNames);

  homeFiles = {
    ".aliases".source = ./templates/.aliases;
    ".ssh/config".source = ./templates/ssh/config;
    ".config/neofetch/config.conf".source = ./templates/neofetch/config.conf;
    ".config/claude-deepseek-settings.json".text = claudeSettings;
    ".claude/settings.json" = { text = claudeSettings; force = true; };
    ".claude/CLAUDE.md".source = ./templates/claude/CLAUDE.md;
  } // claudeAgents // claudeSkills;
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

  programs = (pkgs.callPackage ./apps/zsh.nix {}).programs // {
    home-manager = { enable = true; };
    git = (pkgs.callPackage ./apps/git.nix {}).programs.git;
    neovim = (pkgs.callPackage ./apps/neovim/defaults.nix {}).programs.neovim;
    tmux = (pkgs.callPackage ./apps/tmux.nix {}).programs.tmux;
  };


  # ── Home files (agents, skills, commands, config) ────────────────
  home.file = homeFiles;


  news.display = "silent";

  xdg.enable=true;
  xdg.mime.enable=true;
  targets.genericLinux.enable=true;

}
