{ config, inputs, pkgs, host, ... }:
let
  p = config.colorScheme.palette;
  withA = hex: aa: "#${hex}${aa}";
in
{
  programs.hyprlock = {
    enable = true;
    package = inputs.hyprlock.packages.${pkgs.system}.hyprlock;

    settings = {
      general = {
        hide_cursor = true;
        no_fade_in = false;
        disable_loading_bar = true;
        ignore_empty_input = false;
        fractional_scaling = 0;
      };

      background = [
        {
          monitor = "";
          path = "${../../../wallpapers/blackwave.jpg}";
          blur_passes = 1;
          contrast = 0.90;
          brightness = 0.90;
          vibrancy = 0.20;
          vibrancy_darkness = 0.0;
        }
      ];

      shape = [
        # User box
        {
          monitor = "";
          size = "300, 50";
          color = withA p.base01 "55";
          rounding = 10;
          border_color = withA p.base00 "00";
          position = "0, 120";
          halign = "center";
          valign = "bottom";
        }
      ];
    
      label = [
        # Time
        {
          monitor = "";
          text = ''cmd[update:1000] echo "$(date +'%H:%M')"'';
          color = "#${p.base05}";
          font_size = 115;
          font_family = "Maple Mono Bold";
          shadow_passes = 3;
          position = "0, -25";
          halign = "center";
          valign = "top";
        }
        # Date
        {
          monitor = "";
          text = ''cmd[update:60000] echo "- $(date +'%A, %B %d') -" '';
          color = "#${p.base04}";
          font_size = 18;
          font_family = "Maple Mono";
          position = "0, -225";
          halign = "center";
          valign = "top";
        }
        # Username
        {
          monitor = "";
          text = "$USER";
          color = "#${p.base06}";
          font_size = 15;
          font_family = "Maple Mono Bold";
          position = "0, 131";
          halign = "center";
          valign = "bottom";
        }
      ];

      input-field = [
        {
          monitor = "";
          size = "300, 50";
          outline_thickness = 1;
          rounding = 10;
          
          outer_color = withA p.base01 "33";
          inner_color = withA p.base01 "33";
          color = "#${p.base0D}";
          font_color = "#${p.base05}";
          fail_color = "#${p.base08}";
          font_size = 14;
          font_family = "Maple Mono Bold";

          hide_input = true;
          placeholder_text = ''<i><span foreground="#${p.base0B}">Press Enter to authenticate</span></i>'';

          "fingerprint:enabled" = true;
          "fingerprint:ready_message" = "Press finger to unlock";
          "fingerprint:present_message" = "Scanning fingerprint...";
          "fingerprint:retry_delay" = 250;

          position = "0, 131";
          halign = "center";
          valign = "bottom";
        }
      ];
    };
  };
}
