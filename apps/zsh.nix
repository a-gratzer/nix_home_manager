{ lib, fetchFromGitHub }:

{
  programs.zsh = {
    enable = true;
    defaultKeymap = "viins";
    enableAutosuggestions = true;
    enableCompletion = true;

    # turn off this - WARNING: terminal is not fully functional
    initExtra = ''

      export NIX_PATH=${"NIX_PATH:+$NIX_PATH:"}$HOME/.nix-defexpr/channels:/nix/var/nix/profiles/per-user/root/channels
      . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"


      USE_POWERLINE="true"
      export TERM=xterm
      if [ -f ~/.aliases ]; then
          . ~/.aliases
      fi

      # Manjaro specific
      source "$(fzf-share)/key-bindings.zsh"
      source "$(fzf-share)/completion.zsh"
      source /usr/share/zsh/manjaro-zsh-prompt

      [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

      complete -o default -F __start_kubectl k
      export KUBECONFIG=~/.kube/config

      #THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
      export SDKMAN_DIR="$HOME/.sdkman"
      [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
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