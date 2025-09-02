{ config, lib, pkgs, ... }:
{
  # Brave is unfree
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkgs) [ "brave" "brave-browser" ];
  home.packages = [ pkgs.brave ];

  # Make Brave default
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "brave-browser.desktop";
      "x-scheme-handler/http" = "brave-browser.desktop";
      "x-scheme-handler/https" = "brave-browser.desktop";
      "x-scheme-handler/about" = "brave-browser.desktop";
      "x-scheme-handler/unknown" = "brave-browser.desktop";
    };
  };

  home.sessionVariables.BROWSER = "brave-browser";
}
