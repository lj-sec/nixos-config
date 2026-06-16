{ pkgs, ... }:
{
  programs.hyprland = {
    enable = true;
    withUWSM = true;
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
