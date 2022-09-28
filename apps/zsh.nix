{ pkgs, ... }:

{
  programs.zsh = {
    enable = true;

  enableAutosuggestions = true;
  enableVteIntegration = true;


  shellAliases = {
    # da comrade
    da = "direnv allow";
    g = "git";
  };

  initExtra = ''
    mkdir -p $HOME/.tmux
    export TMUX_TMPDIR=$HOME/.tmux
    export DISPLAY=$(grep -m 1 nameserver /etc/resolv.conf | awk '{print $2}'):0
    # Launch in tmux session if we're not already in one
    if [[ -z $TMUX ]]; then
      exec tmux new-session -t 0 \; set-option destroy-unattached
    fi
  '';

  profileExtra = ''
     # Use powerline
     USE_POWERLINE="true"
     # Source manjaro-zsh-configuration
     if [[ -e /usr/share/zsh/manjaro-zsh-config ]]; then
       source /usr/share/zsh/manjaro-zsh-config
     fi
     # Use manjaro zsh prompt
     if [[ -e /usr/share/zsh/manjaro-zsh-prompt ]]; then
       source /usr/share/zsh/manjaro-zsh-prompt
     fi
     
     if [ -n "${commands[fzf-share]}" ]; then
       source "$(fzf-share)/key-bindings.zsh"
       source "$(fzf-share)/completion.zsh"
     fi
     
     [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
     
     # add nix to the path and then start the tmuxinator which is nix based
     if [ -e $HOME/.nix-profile/etc/profile.d/nix.sh ]; then
       source $HOME/.nix-profile/etc/profile.d/nix.sh
       tmuxinator
     fi
     
     source $HOME/.aliases
     
     export NIX_PATH=${NIX_PATH:+$NIX_PATH:}$HOME/.nix-defexpr/channels:/nix
         /var/nix/profiles/per-user/root/channels
     . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
     
     #THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
     export SDKMAN_DIR="$HOME/.sdkman"
     [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bi
         n/sdkman-init.sh"
  '';

  sessionVariables = {
    # Suppress direnv logs
    DIRENV_LOG_FORMAT = "";

    # Don't use nano
    # EDITOR = "vim";
  };

  plugins = [
    {
      name = "fast-syntax-highlighting";
      src = "${pkgs.zsh-fast-syntax-highlighting}/share/zsh/site-functions";
    }
    {
      name = "zsh-vi-mode";
      src = builtins.fetchGit {
        url = "https://github.com/jeffreytse/zsh-vi-mode";
        rev = "9178e6bea2c8b4f7e998e59ef755820e761610c7";
      };
    }
  ];

  oh-my-zsh = {
    enable = true;
    plugins = [
      "git"
      "npm"
      "docker"
      "command-not-found"
      "ubuntu"
      "z"
      "history-substring-search"
    ];
  };
  };
}