{ config, pkgs, ... }:
let
  dir="${config.home.homeDirectory}/Pictures/Screenshots";
in
{
  home.packages = [
    pkgs.grim
    pkgs.swappy
    pkgs.wl-clipboard
  ];

  xdg.userDirs.enable = true;
  wayland.windowManager.hyprland.settings.bind = [
    "$mainMod, S, exec, grimblast --notify --freeze copy area"
    "$mainMod SHIFT, S, exec, grimblast --notify --freeze save area ${dir}"
    "$mainMod, A, exec, grimblast --notify --freeze save area - | swappy -f -"
  ];
}
