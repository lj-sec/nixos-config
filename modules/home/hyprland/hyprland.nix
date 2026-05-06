{ config, pkgs, inputs, ... }:
{
  home.packages = with pkgs; [
    awww
    inputs.hypr-contrib.packages.${pkgs.stdenv.hostPlatform.system}.grimblast
    inputs.hyprpicker.packages.${pkgs.stdenv.hostPlatform.system}.hyprpicker
    wf-recorder
    glib
    wayland
    direnv
    hyprshade
    waybar-lyric
  ];

  systemd.user.targets.hyprland-session.Unit.Wants = [
    "xdg-desktop-autostart.target"
  ];
  
  xdg.userDirs.enable = true;
  xdg.userDirs.setSessionVariables = false;

  wayland.windowManager.hyprland = {
    enable = true; 
  
    xwayland = {
      enable = true;
    };

    systemd = {
      enable = true;
      variables = ["--all"];
    };
  };
}
