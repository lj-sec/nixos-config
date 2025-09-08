{ config, pkgs, username, ... }:
{
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.hyprland}/bin/hyprland";
      user = username;
    };
  };
}