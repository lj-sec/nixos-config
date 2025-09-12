{ config, pkgs, username, ... }:
{
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "hyprland";
      user = username;
    };
  };
}