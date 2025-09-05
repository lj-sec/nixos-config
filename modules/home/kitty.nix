{ config, ... }:
let
  p = config.colorScheme.palette;
  custom = {
    font = "Maple Mono";
    font_size    = 9.0;
    font_weight  = "Bold";
    text_color   = "#${p.base05}";
    background_0 = "#${p.base00}";
    background_1 = "#${p.base01}";
    border_color = "#${p.base03}";
    red     = "#${p.base08}";
    orange  = "#${p.base09}";
    yellow  = "#${p.base0A}";
    green   = "#${p.base0B}";
    cyan    = "#${p.base0C}";
    blue    = "#${p.base0D}";
    magenta = "#${p.base0E}";
    brown   = "#${p.base0F}";
    opacity = "0.75"; 
  };
in
{
  programs.kitty = with custom; {
    enable = true;
    settings = {
      foreground = "${text_color}";
      background = "${background_0}";

      color0 = background_0;
      color1 = red;
      color2 = green;
      color3 = yellow;
      color4 = blue;
      color5 = magenta;
      color6 = cyan;
      color7 = text_color;
      color8 = border_color;
      color9 = red;
      color10 = green;
      color11 = yellow;
      color12 = blue;
      color13 = magenta;
      color14 = cyan;
      color15 = "#${p.base07}";
      
      url_color = blue;

      background_opacity = "${opacity}";
      dynamic_background_opacity = "yes";

      font_size = font_size;

      confirm_os_window_close = 0;
    };
  };
}
