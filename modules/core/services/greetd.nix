{ config, pkgs, username, ... }:
let
  # Wrapper to prevent Hyprland from printing to the console
  startHypr = pkgs.writeShellScript "start-hyprland" ''
    exec Hyprland >/dev/null 2>&1
  '';
in {
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${startHypr}";
      user = username;
    };
  };
}