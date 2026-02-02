{ config, pkgs, username, ... }:
let
  startHypr = pkgs.writeShellScript "start-hyprland" ''
    exec /run/current-system/sw/bin/start-hyprland >/dev/null 2>&1
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