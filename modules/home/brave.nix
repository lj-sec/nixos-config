{ pkgs, ... }:
{
  programs.brave = {
    enable = true;
    package = pkgs.brave;
  };

  home.sessionVariables.BROWSER = "brave";
}
