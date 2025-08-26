{ config, pkgs, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    settings = {
      "$mod" = "SUPER";
      bind = [
        "SUPER, RETURN, exec ${pkgs.kitty}/bin/kitty"
        "SUPER, Q, killactive"
      ];
    };
  };

  programs.waybar.enable = true;

  services.swaync.enable = true;
  services.swaync.settings = {
    workspace = 10;
    output = "eDP-1";
  };

  home.packages = with pkgs; [
    hyprland
    hyprpaper
    hyprpicker
    waybar
    kitty
    rofi
    grim
    slurp
    wl-clipboard
    pamixer
    pavucontrol
    kitty
    brave
    ffmpegthumbnailer 
  ];

}
