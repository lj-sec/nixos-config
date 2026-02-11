{ config, lib, pkgs, ... }:
{
  home.packages = with pkgs; [
    brave    
  ];

  # Make Brave default
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "com.brave.Browser.desktop";
      "x-scheme-handler/http" = "com.brave.Browser.desktop";
      "x-scheme-handler/https" = "com.brave.Browser.desktop";
      "x-scheme-handler/about" = "com.brave.Browser.desktop";
      "x-scheme-handler/unknown" = "com.brave.Browser.desktop";

      "x-scheme-handler/slack"  = "slack.desktop";
    };
  };

  home.sessionVariables.BROWSER = "brave";
}
