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

  programs = (pkgs.callPackage ./apps/zsh.nix {}).programs // {
    home-manager = { enable = true; };
    git = (pkgs.callPackage ./apps/git.nix {}).programs.git;
    neovim = (pkgs.callPackage ./apps/neovim/defaults.nix {}).programs.neovim;
    tmux = (pkgs.callPackage ./apps/tmux.nix {}).programs.tmux;
  };


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

  # ── Claude Code agents ────────────────────────────────────────────
  home.file.".claude/agents/java-springboot.md".source = ./templates/claude/agents/java-springboot.md;
  home.file.".claude/agents/golang.md".source = ./templates/claude/agents/golang.md;
  home.file.".claude/agents/ansible.md".source = ./templates/claude/agents/ansible.md;
  home.file.".claude/agents/kubernetes.md".source = ./templates/claude/agents/kubernetes.md;
  home.file.".claude/agents/linux-admin.md".source = ./templates/claude/agents/linux-admin.md;
  home.file.".claude/agents/docker-optimization.md".source = ./templates/claude/agents/docker-optimization.md;

  # ── Claude Code skills ────────────────────────────────────────────
  home.file.".claude/skills/java-springboot.md".source = ./templates/claude/skills/java-springboot.md;
  home.file.".claude/skills/golang.md".source = ./templates/claude/skills/golang.md;
  home.file.".claude/skills/ansible.md".source = ./templates/claude/skills/ansible.md;
  home.file.".claude/skills/kubernetes.md".source = ./templates/claude/skills/kubernetes.md;
  home.file.".claude/skills/linux-admin.md".source = ./templates/claude/skills/linux-admin.md;
  home.file.".claude/skills/docker-optimization.md".source = ./templates/claude/skills/docker-optimization.md;
  home.file.".claude/skills/commit-push.md".source = ./.claude/skills/commit-push.md;

  news.display = "silent";

  xdg.enable=true;
  xdg.mime.enable=true;
  targets.genericLinux.enable=true;

}
