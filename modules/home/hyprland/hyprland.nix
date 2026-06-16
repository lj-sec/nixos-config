{ pkgs, lib, installFeatures ? {}, ... }:
let
  feature = name:
    if builtins.hasAttr name installFeatures then installFeatures.${name} else true;
in
{
  home.packages = with pkgs; [
    awww
    grimblast
    hyprpicker
    wf-recorder
    glib
    wayland
    direnv
    hyprshade
  ]
  ++ lib.optionals (feature "music") [
    waybar-lyric
  ];

  xdg.userDirs.enable = true;
  xdg.userDirs.setSessionVariables = false;

  wayland.windowManager.hyprland = {
    enable = true;
    configType = "hyprlang";

    xwayland = {
      enable = true;
    };

    systemd.enable = false;
  };
}
