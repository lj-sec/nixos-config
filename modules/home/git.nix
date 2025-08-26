{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;
    userName = "lj-sec";
    userEmail = "126737129+lj-sec@users.noreply.github.com";
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = false;
      credential.helper = "!gh auth git-credential";
    };
  };
  home.packages = [ pkgs.gh ];
}
