{ config, pkgs, inputs, lib, installFeatures ? {}, ... }:
let
  system = pkgs.stdenv.hostPlatform.system;
  feature = name:
    if builtins.hasAttr name installFeatures then installFeatures.${name} else true;
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
  ]
  ++ lib.optionals (feature "music") [
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
