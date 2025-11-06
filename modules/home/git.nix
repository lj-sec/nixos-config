{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "lj-sec";
        email = "126737129+lj-sec@users.noreply.github.com";
      };
      init.defaultBranch = "main";
      pull.rebase = false;
      credential.helper = "!gh auth git-credential";
    };
  };
  home.packages = with pkgs; [
    gh
  ];
}
