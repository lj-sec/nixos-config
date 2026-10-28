{ config, pkgs, username, ... }:
let
  startHypr = pkgs.writeShellScript "start-hyprland-uwsm" ''
    # Keep session startup output in the journal instead of flashing it on VT1.
    exec ${config.systemd.package}/bin/systemd-cat --identifier=uwsm \
      ${pkgs.uwsm}/bin/uwsm start -e -D Hyprland ${config.programs.hyprland.package}/share/wayland-sessions/hyprland.desktop
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
