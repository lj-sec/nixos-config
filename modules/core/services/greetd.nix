{ config, pkgs, username, ... }:
let
  startHypr = pkgs.writeShellScript "start-hyprland-uwsm" ''
    exec ${pkgs.uwsm}/bin/uwsm start -e -D Hyprland ${config.programs.hyprland.package}/share/wayland-sessions/hyprland.desktop
  '';
in {
  services.greetd = {
    enable = true;
    settings = {
      initial_session = {
        command = "${startHypr}";
        user = username;
      };

      default_session = {
        command = "${pkgs.greetd}/bin/agreety --cmd ${startHypr}";
        user = "greeter";
      };
    };
  };
}