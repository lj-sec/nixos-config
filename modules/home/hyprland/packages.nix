{ pkgs, ... }:
{
  home.packages = with pkgs; [
    hyprland
    hyprpaper
    hyprpicker
    grim
    slurp
    wl-clipboard
    pamixer
    pavucontrol
    brave
    ffmpegthumbnailer
  ];
}
