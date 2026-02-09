{ config, inputs, pkgs, host, ... }:
let
  p = config.colorScheme.palette;
  withA = hex: aa: "#${hex}${aa}";
  font = "0xProto Nerd Font";
in
{
  programs.hyprlock = {
    enable = true;
    package = inputs.hyprlock.packages.${pkgs.stdenv.hostPlatform.system}.hyprlock;

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
          path = "${../../../wallpapers/blackwave-cat.jpg}";
          blur_passes = 1;
          contrast = 0.90;
          brightness = 0.90;
          vibrancy = 0.20;
          vibrancy_darkness = 0.0;
        }
      ];
    
      label = [
        # Time
        {
          monitor = "";
          text = ''cmd[update:1000] echo " $(date +'%H:%M')"'';
          color = "#${p.base05}";
          font_size = 115;
          font_family = "${font}";
          shadow_passes = 3;
          position = "250, -50";
          halign = "center";
          valign = "center";
        }
        # Date
        {
          monitor = "";
          text = ''cmd[update:60000] echo "- $(date +'%A, %B %d') -" '';
          color = "#${p.base04}";
          font_size = 18;
          font_family = "${font}";
          position = "250, -150";
          halign = "center";
          valign = "center";
        }
        # Username
        {
          monitor = "";
          text = "$USER";
          color = "#${p.base06}";
          font_size = 15;
          font_family = "${font}";
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
          fail_text = "$FAIL";
          fail_transition = 300;
          font_size = 14;
          font_family = "${font}";

          hide_input = true;
          placeholder_text = ''Press Enter to authenticate'';

          position = "0, 125";
          halign = "center";
          valign = "bottom";
        }
      ];
    };
  };
}
