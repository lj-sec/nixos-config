{ config, pkgs, inputs, ... }:

{
  home.packages = with pkgs; [
    swww
    inputs.hypr-contrib.packages.${pkgs.system}.grimblast
    inputs.hyprpicker.packages.${pkgs.system}.hyprpicker
    wf-recorder
    glib
    wayland
    direnv
  ];

  systemd.user.targets.hyprland-session.Unit.Wants = [
    "xdg-desktop-autostart.target"
  ];
  
  xdg.userDirs.enable = true;

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
