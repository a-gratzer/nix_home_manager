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
    #programs.zsh.autosuggesetions.enable = true;
    enableCompletion = true;

    # turn off this - WARNING: terminal is not fully functional
    initExtra = ''

      # Use powerline
      USE_POWERLINE="true"

      [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
      
      source $HOME/.aliases

      export NIX_PATH=$HOME/.nix-defexpr/channels:/nix/var/nix/profiles/per-user/root/channels
      . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"


      #THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
      export SDKMAN_DIR="$HOME/.sdkman"
      [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

      complete -o default -F __start_kubectl k
      export KUBECONFIG=~/.kube/config
      export XDG_DATA_DIRS=\"$HOME/.nix-profile/share:$XDG_DATA_DIRS\"

      export SDKMAN_DIR="/home/ag/.sdkman"
      [[ -s \"/home/ag/.sdkman/bin/sdkman-init.sh\" ]] && source \"/home/ag/.sdkman/bin/sdkman-init.sh\"


      # MAVEN
      export M2_HOME=/home/ag/.sdkman/candidates/maven/current
      export M2=$M2_HOME/bin
      export PATH=$M2:$PATH

      # VISUALVM
      export VISUALVM_HOME=/home/ag/.sdkman/candidates/visualvm/current
      export PATH=$VISUALVM_HOME:$PATH

      neofetch --ascii ~/.config/neofetch/terminal-ascii.txt
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
      theme = "gnzh";
      #theme = "alanpeabody";
      #theme = "dieter";
      plugins = [
      
      	#"dnf"
      	"colorize"
      	"aws"
        "git"
        "vi-mode"
        #"golang"
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
