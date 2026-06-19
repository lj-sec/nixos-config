{ config, pkgs, ... }:

let
  fontName   = "0xProto Nerd Font";
  fontSize   = 10;
  cursorSize = 16;

  flavor = config.catppuccin.flavor;
  accent = config.catppuccin.accent;

  # Theme dir names for catppuccin-cursors are lowercase now (what apps actually look up).
  cursorName = "catppuccin-${flavor}-${accent}-cursors";
in
{
  home.packages = with pkgs; [
    magnetic-catppuccin-gtk
  ];

  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    size = cursorSize;
  };

  home.sessionVariables = {
    XCURSOR_THEME = cursorName;
    XCURSOR_SIZE  = toString cursorSize;
  };

  systemd.user.sessionVariables = {
    XCURSOR_THEME = cursorName;
    XCURSOR_SIZE  = toString cursorSize;
  };

  gtk = {
    enable = true;

    gtk4 = {
      theme = null;
    };

    font = {
      name = fontName;
      size = fontSize;
    };

    theme = {
      package = pkgs.magnetic-catppuccin-gtk;
      name = "Catppuccin-GTK-Dark";
    };

    iconTheme = {
      name = "Papirus-Dark";
    };

    cursorTheme = {
      name = cursorName;
      size = cursorSize;
    };
  };
}
