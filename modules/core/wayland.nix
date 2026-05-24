{ inputs, pkgs, ... }:
let
  system = pkgs.stdenv.hostPlatform.system;
  hyprlandPackage = inputs.hyprland.packages.${system}.default.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      ./patches/hyprland-device-config-null-guard.patch
    ];
  });
in
{
  programs.hyprland = {
    enable = true;
    package = hyprlandPackage;
    withUWSM = true;
    portalPackage = inputs.hyprland.packages.${system}.xdg-desktop-portal-hyprland;
  };

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = false;

    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
    ];

    config = {
      common.default = [ "hyprland" "gtk" ];

      hyprland = {
        default = [ "hyprland" "gtk" ];

        "org.freedesktop.impl.portal.OpenURI" = [ "gtk" ];
        "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
        "org.freedesktop.impl.portal.Settings" = [ "gtk" ];
      };
    };
  };
}
