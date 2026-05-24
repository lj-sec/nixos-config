{ config, pkgs, inputs, ... }:
let
  system = pkgs.stdenv.hostPlatform.system;
  hyprlandPackage = inputs.hyprland.packages.${system}.default.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      ./../../core/patches/hyprland-device-config-null-guard.patch
    ];
  });
in
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

  xdg.userDirs.enable = true;
  xdg.userDirs.setSessionVariables = false;

  wayland.windowManager.hyprland = {
    enable = true;
    package = hyprlandPackage;

    xwayland = {
      enable = true;
    };

    systemd.enable = false;
  };
}
