{ config, pkgs, lib, ... }:

let
  fontName = "0xProto Nerd Font";
  fontSize = 9;
  cursorSize = 12;
in
{
  home.packages = with pkgs; [
    papirus-icon-theme
    magnetic-catppuccin-gtk
  ];

  home.pointerCursor = {
    gtk.enable = true;
    package = pkgs.afterglow-cursors-recolored;
    name = "Afterglow-Recolored-Dracula-Red";
    size = cursorSize;
  };

  gtk = {
    enable = true;

    font = {
      name = fontName;
      size = fontSize;
    };

    theme = {
      package = pkgs.magnetic-catppuccin-gtk;
      name = "Catppuccin-GTK-Dark";
    };

    iconTheme = {
      package = pkgs.papirus-icon-theme;
      name = "Papirus-Dark";
    };

  };
}