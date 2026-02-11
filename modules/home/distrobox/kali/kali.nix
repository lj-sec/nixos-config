{ config, pkgs, lib, ... }:
let
  ensureKali = pkgs.writeShellScript "ensure-kali-distrobox" ''
    set -euo pipefail

    # Create if missing
    if ! ${pkgs.distrobox}/bin/distrobox list | ${pkgs.gnugrep}/bin/grep -qE '^\S+\s+\|\s+kali\s+\|'; then
      ${pkgs.distrobox}/bin/distrobox create -n kali -i docker.io/kalilinux/kali-rolling:latest
    fi

    # Run bootstrap (idempotent)
    ${pkgs.distrobox}/bin/distrobox enter kali -- bash -lc "$HOME/.config/distrobox/kali/bootstrap.sh"
  '';
in
{
  home.packages = with pkgs; [
    podman
    crun
    distrobox
  ];

  # Make these visible inside the container
  home.file.".config/distrobox/kali/apt-packages.txt".source = ./apt-packages.txt;

  home.file.".config/distrobox/kali/bootstrap.sh" = {
    source = ./bootstrap.sh;
    executable = true;
  };

  # Oneshoot service
  systemd.user.services.kali-distrobox-ensure = {
    Unit = {
      Description = "Ensure Kali distrobox exists and is bootstrapped";
      After = [ "network-online.target" ];
      Wants = [ "network-online.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = ensureKali;
      TimeoutStartSec = "30min";
    };
    Install = {
      WantedBy = [ ];
    };
  };

  # Run it on every Home Manager switch, after systemd units are reloaded.
  # This starts the service and returns immediately; it won't block or fail the rebuild.
  home.activation.kaliDistroboxBootstrap =
    lib.hm.dag.entryAfter [ "reloadSystemd" ] ''
      ${pkgs.systemd}/bin/systemctl --user start kali-distrobox-ensure.service || true
    '';
}
