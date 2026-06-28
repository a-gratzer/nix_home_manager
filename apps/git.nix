{ google-chrome, meld }:

{
  programs.git = {
    enable = true;
    settings = {
      user.name = "Andreas Gratzer";
      user.email = "gratzer.andreas@gmail.com";
      alias.st = "status";
      alias.co = "checkout";
      alias.br = "branch";
      alias.f = "fetch";
      alias.m = "merge";
      alias.lg = "log --graph --format='%Cred%h%Creset  %<|(15) %white)%s %<|(35) %Creset %Cgreen(%cr)%<|(55)  %C(blue)<%an>%Creset%C(yellow)%d%Creset'";
      web.browser = "${google-chrome}/bin/google-chrome";
      core.editor = "vim";
      diff.tool = "meld";
      difftool.prompt = false;
      difftool.cmd = "${meld}/bin/meld $LOCAL $REMOTE";
      merge.tool = "meld";
      mergetool.cmd = "${meld}/bin/meld $LOCAL $MERGED $REMOTE";
      mergetool.keepBackup = false;
    };

    ignores = [
      ".idea"
      "*.swp"
      "*~"
      "#*"
      ".DS_Store"
    ];
  };
}
