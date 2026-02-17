{ config, pkgs, lib, ... }:
let
  ensureKali = pkgs.writeShellScript "ensure-kali-distrobox" ''
    set -euo pipefail

    log() { echo "[kali-distrobox-ensure] $*"; }

    has_kali() {
      # Avoid brittle grep on table formatting
      ${pkgs.distrobox}/bin/distrobox list --no-color 2>/dev/null \
        | ${pkgs.gawk}/bin/awk -F'|' '
            NR>1 {
              name=$2; gsub(/[[:space:]]/, "", name);
              if (name == "kali") found=1
            }
            END { exit(found ? 0 : 1) }'
    }

    recreate() {
      log "Removing and recreating kali distrobox..."
      ${pkgs.distrobox}/bin/distrobox rm -f kali >/dev/null 2>&1 || true
      ${pkgs.distrobox}/bin/distrobox-create -n kali -i docker.io/kalilinux/kali-rolling:latest
    }

    log "Checking for kali distrobox..."
    if ! has_kali; then
      log "Not found; creating..."
      ${pkgs.distrobox}/bin/distrobox-create -n kali -i docker.io/kalilinux/kali-rolling:latest
    fi

    log "Running bootstrap..."
    set +e
    out="$(${pkgs.distrobox}/bin/distrobox enter kali -- bash -lc "$HOME/.config/distrobox/kali/bootstrap.sh" 2>&1)"
    rc=$?
    set -e

    if [ $rc -ne 0 ]; then
      # Common failure mode on NixOS after upgrades: stale /nix/store path referenced
      if echo "$out" | ${pkgs.gnugrep}/bin/grep -qE 'cannot stat .*/distrobox-(host-exec|export)'; then
        log "Detected stale distrobox helper path; recreating container..."
        recreate
        ${pkgs.distrobox}/bin/distrobox enter kali -- bash -lc "$HOME/.config/distrobox/kali/bootstrap.sh"
        log "Bootstrap complete after recreate."
        exit 0
      fi

      echo "$out" >&2
      exit $rc
    fi

    log "Bootstrap complete."
  '';
in
{
  home.packages = with pkgs; [ podman crun distrobox ];

  home.file.".config/distrobox/kali/apt-packages.txt".source = ./apt-packages.txt;

  home.file.".config/distrobox/kali/bootstrap.sh" = {
    source = ./bootstrap.sh;
    executable = true;
  };

  systemd.user.services.kali-distrobox-ensure = {
    Unit = {
      Description = "Ensure Kali distrobox exists and is bootstrapped";
      # Since you explicitly start it from activation, these ordering deps often just cause “queued forever” behavior.
      # Keep it simple unless you’ve proven you need them.
    };
    Service = {
      Type = "oneshot";
      ExecStart = ensureKali;
      TimeoutStartSec = "30min";

      # Make journal output easy to find/read
      SyslogIdentifier = "kali-distrobox-ensure";
      StandardOutput = "journal";
      StandardError = "journal";
    };
    Install = { WantedBy = [ ]; };
  };

  # Print to the rebuild terminal, *then* start in the background.
  home.activation.kaliDistroboxBootstrap =
    lib.hm.dag.entryAfter [ "reloadSystemd" ] ''
      echo "==> Queuing Kali distrobox bootstrap in the background"
      echo "==> Follow: journalctl --user -fu kali-distrobox-ensure.service"

      if ! ${pkgs.systemd}/bin/systemctl --user start --no-block kali-distrobox-ensure.service; then
        echo "==> (kali-distrobox-ensure) failed to queue; check: systemctl --user status kali-distrobox-ensure.service"
      fi
    '';
}