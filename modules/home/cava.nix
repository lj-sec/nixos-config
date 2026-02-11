{ pkgs, config, ... }:
let
  p = config.colorScheme.palette;
in
{
  programs.cava = {
    enable = true;
    settings = {
      general = {
        bar_spacing = 1;
        bar_width = 2;
        frame_rate = 60;
      };
      color = {
        gradient = 1;
        gradient_color_1 = "#${p.base0D}";
        gradient_color_2 = "#${p.base0C}";
        gradient_color_3 = "#${p.base0E}";
        gradient_color_4 = "#${p.base0E}";
        gradient_color_5 = "#${p.base0E}";
        gradient_color_6 = "#${p.base09}";
        gradient_color_7 = "#${p.base09}";
        gradient_color_8 = "#${p.base08}";
      };
    };
  };
}