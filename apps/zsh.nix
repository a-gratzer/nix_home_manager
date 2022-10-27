{ config, lib, pkgs, fetchFromGitHub, ...  }:

{
  programs.broot = {
    enable = true;
    enableFishIntegration = true;
    enableZshIntegration = true;
  };


  programs.zsh = {
    enable = true;
    defaultKeymap = "viins";
    enableAutosuggestions = true;
    enableCompletion = true;

    # turn off this - WARNING: terminal is not fully functional
    initExtra = ''

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

      [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

      # add nix to the path and then start the tmuxinator which is nix based
      if [ -e $HOME/.nix-profile/etc/profile.d/nix.sh ]; then
        source $HOME/.nix-profile/etc/profile.d/nix.sh
        tmuxinator
      fi

      source $HOME/.aliases

      export NIX_PATH=$HOME/.nix-defexpr/channels:/nix/var/nix/profiles/per-user/root/channels
      . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"


      #THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
      export SDKMAN_DIR="$HOME/.sdkman"
      [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

      complete -o default -F __start_kubectl k
      export KUBECONFIG=~/.kube/config

    '';

    shellAliases = {

    };

    # .zshrc will get updated to source this plugin automatically
    plugins = [
      {
        # nix-prefetch-url --unpack https://github.com/zsh-users/zsh-syntax-highlighting/archive/0.6.0.tar.gz
        name = "zsh-syntax-highlighting";
        src = fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-syntax-highlighting";
          rev = "0.6.0";
          sha256 = "0zmq66dzasmr5pwribyh4kbkk23jxbpdw4rjxx0i7dx8jjp2lzl4";
        };
      }
    ];

    # out of the box plugins - https://github.com/robbyrussell/oh-my-zsh/tree/master/plugins
    oh-my-zsh = {
      enable = true;
      theme = "eastwood";
      plugins = [
        "git"
        "vi-mode"
        "golang"
        "colored-man-pages"
        "docker"
        "npm"
        "pip"
        "python"
        "sudo"
        "systemd"
      ];
    };
  };
}