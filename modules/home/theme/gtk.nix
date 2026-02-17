{ config, pkgs, lib, ... }:

let
  fontName   = "0xProto Nerd Font";
  fontSize   = 10;
  cursorSize = 12;

  flavor = "mocha";
  accent = "lavender";

  # nixpkgs exposes Catppuccin cursors as sub-attrs like `mochaMauve`, `mochaLavender`, etc.
  cursorPkg = pkgs.catppuccin-cursors.mochaLavender;

  # Catppuccin Papirus folders is meant to be used via an override for flavor/accent.
  folderPkg = pkgs.catppuccin-papirus-folders.override { inherit flavor accent; };

  # Theme dir names for catppuccin-cursors are lowercase now (what apps actually look up).
  cursorName = "catppuccin-${flavor}-${accent}-cursors";
in
{
  home.packages = with pkgs; [
    cursorPkg
    folderPkg
    magnetic-catppuccin-gtk
  ];

  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = cursorPkg;
    name = cursorName;
    size = cursorSize;
  };

  home.sessionVariables = {
    XCURSOR_THEME = cursorName;
    XCURSOR_SIZE  = toString cursorSize;
    HYPRCURSOR_THEME = cursorName;
    HYPRCURSOR_SIZE  = toString cursorSize;
  };

  gtk = lib.mkForce {
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
      package = folderPkg;
      name = "Papirus-Dark";
    };

    cursorTheme = {
      package = cursorPkg;
      name = cursorName;
      size = cursorSize;
    };
  };
}
