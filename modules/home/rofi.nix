{ config, lib, pkgs, ... }:
let
  p = config.colorScheme.palette;
  inherit (config.lib.formats.rasi) mkLiteral;
in
{
  programs.rofi = {
    enable = true;
    # Pin the upstream Wayland click-to-exit implementation instead of using
    # global mouse hooks, which can close Rofi on the same click that opens it.
    package = pkgs.rofi.override {
      rofi-unwrapped = pkgs.rofi-unwrapped.overrideAttrs (_: {
        src = pkgs.fetchFromGitHub {
          owner = "davatorium";
          repo = "rofi";
          rev = "6d2a5281e45dee92dfbdaf6f9ba6081c4c608682";
          fetchSubmodules = true;
          hash = "sha256-4F76JPNaM43DgnM+F0WoYvL5aBbyPSZt3q0YWKAQ9Zs=";
        };
      });
    };
    cycle = false;
    font = "0xProto Nerd Font 13px";
    location = "top-left";
    modes = [ "run" "drun" "window" ];
    terminal = "kitty";
    xoffset = 8;
    yoffset = 8;

    extraConfig = {
      "click-to-exit" = true;
      "disable-history" = true;
      "display-drun" = "Apps";
      "display-run" = "Run";
      "display-window" = "Window";
      "drun-display-format" = "{name}";
      "hide-scrollbar" = true;
      "icon-theme" = "Papirus-dark";
      lines = 5;
      "show-icons" = true;
      "sidebar-mode" = true;
      "sorting-method" = "fzf";
    };

    # Match SwayNC's panel, cards and green accent instead of Catppuccin's layout.
    theme = lib.mkForce {
      "*" = {
        panel = mkLiteral "#${p.base00}";
        card = mkLiteral "#${p.base01}";
        surface = mkLiteral "#${p.base02}";
        outline = mkLiteral "#${p.base03}";
        muted = mkLiteral "#${p.base04}";
        foreground = mkLiteral "#${p.base05}";
        accent = mkLiteral "#${p.base0B}";
        danger = mkLiteral "#${p.base08}";
        background-color = mkLiteral "transparent";
        text-color = mkLiteral "@foreground";
        border-color = mkLiteral "@outline";
        border = 0;
        margin = 0;
        padding = 0;
        spacing = 0;
      };

      window = {
        width = mkLiteral "410px";
        background-color = mkLiteral "@panel";
        border = mkLiteral "1px";
        border-radius = mkLiteral "8px";
        padding = mkLiteral "14px";
      };

      mainbox = {
        children = [ "inputbar" "listview" "message" "mode-switcher" ];
        spacing = mkLiteral "12px";
      };

      inputbar = {
        children = [ "prompt" "entry" ];
        background-color = mkLiteral "@card";
        border = mkLiteral "1px";
        border-radius = mkLiteral "6px";
        padding = mkLiteral "10px";
        spacing = mkLiteral "10px";
      };
      prompt = {
        text-color = mkLiteral "@accent";
      };
      entry = {
        placeholder = "Search...";
        placeholder-color = mkLiteral "@muted";
        cursor = mkLiteral "text";
      };

      listview = {
        columns = 1;
        lines = 5;
        fixed-height = true;
        scrollbar = false;
        spacing = mkLiteral "8px";
      };
      element = {
        children = [ "element-icon" "element-text" ];
        background-color = mkLiteral "@card";
        border = mkLiteral "1px 1px 1px 3px";
        border-radius = mkLiteral "6px";
        padding = mkLiteral "12px";
        spacing = mkLiteral "10px";
        cursor = mkLiteral "pointer";
      };
      "element normal.normal, element alternate.normal" = {
        background-color = mkLiteral "@card";
        text-color = mkLiteral "@foreground";
      };
      "element normal.active, element alternate.active" = {
        background-color = mkLiteral "@card";
        text-color = mkLiteral "@accent";
      };
      "element normal.urgent, element alternate.urgent" = {
        background-color = mkLiteral "@card";
        text-color = mkLiteral "@danger";
      };
      "element selected.normal, element selected.active, element selected.urgent" = {
        background-color = mkLiteral "@surface";
        text-color = mkLiteral "@foreground";
        border-color = mkLiteral "@accent";
      };
      element-icon = {
        size = mkLiteral "28px";
      };
      element-text = {
        vertical-align = mkLiteral "0.5";
        text-color = mkLiteral "inherit";
        highlight = mkLiteral "bold";
      };

      mode-switcher = {
        border = mkLiteral "1px 0px 0px";
        border-color = mkLiteral "@surface";
        padding = mkLiteral "12px 0px 0px";
        spacing = mkLiteral "8px";
      };
      button = {
        background-color = mkLiteral "@card";
        border = mkLiteral "1px";
        border-radius = mkLiteral "4px";
        padding = mkLiteral "6px 10px";
        cursor = mkLiteral "pointer";
      };
      "button selected" = {
        background-color = mkLiteral "@surface";
        border-color = mkLiteral "@accent";
        text-color = mkLiteral "@accent";
      };

      message = {
        background-color = mkLiteral "@card";
        border = mkLiteral "1px";
        border-radius = mkLiteral "6px";
        padding = mkLiteral "10px";
      };
      textbox = {
        text-color = mkLiteral "@foreground";
      };
    };
  };
}
