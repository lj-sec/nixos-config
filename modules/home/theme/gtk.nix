{ config, pkgs, lib, ... }:

let
  fontName = "0xProto Nerd Font";
  fontSize = 9;
in
{
  home.packages = with pkgs; [
    papirus-icon-theme
    adw-gtk3
  ];

  gtk = {
    enable = true;

    font = {
      name = fontName;
      size = fontSize;
    };

    theme = {
      package = pkgs.adw-gtk3;
      name = "adw-gtk3-dark";
    };

    iconTheme = {
      package = pkgs.papirus-icon-theme;
      name = "Papirus-Dark";
    };

  };
}