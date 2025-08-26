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
}
