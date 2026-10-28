{ ... }:

{
  imports = [
    ./git.nix
    ./btop.nix
    ./fish.nix
    ./fastfetch.nix
  ];

  home.stateVersion = "24.05";

  programs.home-manager.enable = true;

  home.sessionVariables = {
    EDITOR = "vim";
    VISUAL = "vim";
    PAGER = "less";
  };
}
