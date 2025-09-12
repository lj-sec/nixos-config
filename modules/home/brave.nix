{ config, lib, pkgs, ... }:
{
  home.packages = with pkgs; [ 
    brave
  ];

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
