{ pkgs, ... }:

{
  programs.broot = {
    enable = true;
    enableFishIntegration = true;
    enableZshIntegration = true;
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableZshIntegration = true;
  };

  programs.zsh = {
    enable = true;
    defaultKeymap = "viins";
    enableCompletion = true;

    # ── Built-in plugin modules (replaces manual fetchFromGitHub) ──
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # ── History ──
    history = {
      size = 50000;
      save = 50000;
      path = "$HOME/.zsh_history";
      ignoreDups = true;
      ignoreSpace = true;            # commands starting with space aren't saved
      share = true;                  # share history across sessions
      expireDuplicatesFirst = true;
      extended = true;               # save timestamps
    };

    # ── Options ──
    autocd = true;                   # type directory name to cd into it

    initExtra = ''
      # Powerline
      USE_POWERLINE="true"

      # FZF
      [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

      # Aliases
      source "$HOME/.aliases"

      # Home-manager session vars
      . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"

      # Load secrets (no_git/.env — not tracked in Git)
      [ -f "$HOME/.local/share/nix-home-manager/.env" ] && source "$HOME/.local/share/nix-home-manager/.env"
      [ -f "$HOME/workspace/nix_home_manager/no_git/.env" ] && source "$HOME/workspace/nix_home_manager/no_git/.env"

      # SDKMAN (must be last)
      export SDKMAN_DIR="$HOME/.sdkman"
      [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

      # Kubernetes
      export KUBECONFIG=~/.kube/config

      # PATH
      export XDG_DATA_DIRS="$HOME/.nix-profile/share:$XDG_DATA_DIRS"
      export PATH="$HOME/.local/bin:$PATH"

      # SDKMAN paths
      export M2_HOME="$HOME/.sdkman/candidates/maven/current"
      export M2="$M2_HOME/bin"
      export PATH="$M2:$PATH"
      export VISUALVM_HOME="$HOME/.sdkman/candidates/visualvm/current"
      export PATH="$VISUALVM_HOME:$PATH"

      # Vault (only if the vault-keys file exists — avoids errors when absent)
      if [ -f /home/ag/workspace/devops/contabo/ignore/vault-keys.json ]; then
        export VAULT_ADDR=https://vault.gratzer.cloud
        export VAULT_TOKEN=$(jq -r '.root_token' /home/ag/workspace/devops/contabo/ignore/vault-keys.json)
      fi

      # Welcome
      fastfetch
    '';

    shellAliases = { };

    # ── Manual plugins (only fzf-tab needs manual fetch now) ──
    plugins = [
      {
        name = "fzf-tab";
        src = pkgs.fetchFromGitHub {
          owner = "Aloxaf";
          repo = "fzf-tab";
          rev = "v1.1.2";
          sha256 = "1b4pksrc573aklk71dn2zikiymsvq19bgvamrdffpf7azpq6kxl2";
        };
      }
    ];

    oh-my-zsh = {
      enable = true;
      theme = "gnzh";
      plugins = [
        "colorize"
        "aws"
        "git"
        "vi-mode"
        "colored-man-pages"
        "docker"
        "npm"
        "pip"
        "python"
        "sudo"
        "systemd"
        # ── New additions ──
        "z"               # jump to frequent directories by fuzzy name
        "extract"         # universal archive extractor (x tar.gz zip rar 7z ...)
        "kubectl"         # completion + k/kctx/kns aliases
        "helm"            # completion for helm
        "fzf"             # Ctrl-T (files), Ctrl-R (history), Alt-C (dirs)
        "direnv"          # shell integration for direnv
      ];
    };
  };
}
