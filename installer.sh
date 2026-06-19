#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib.sh
source "$script_dir/scripts/lib.sh"

repo="$(repo_root)"
cd "$repo"

usage() {
  cat <<'USAGE'
Usage: ./installer.sh

Interactive front door for:
  1. rebuilding an installed system
  2. installing an existing host to an already mounted /mnt
  3. wiping a selected disk and installing an existing host
USAGE
}

run_rebuild() {
  require_cmd nixos-rebuild sudo

  local host network_hostname driver_profile username features
  host="$(select_host "$repo")"
  network_hostname="$(select_network_hostname "$host")"
  driver_profile="$(select_driver_profile "$(default_driver_profile "$host")")"
  username="$(prompt_default "NixOS username" "${USER:-curse}")"
  validate_username "$username" || die "Invalid username: $username"
  features="$(select_features)"

  cat <<SUMMARY

Rebuild summary
---------------
Flake host:          $host
Networking hostname: $network_hostname
Driver profile:      $driver_profile
Username:            $username
Features:            $(features_summary "$features")
Command:             sudo nixos-rebuild switch --flake .#$host
SUMMARY

  confirm_yes_no "Run this rebuild?" "n" || die "Rebuild cancelled."
  "$repo/scripts/preflight-rebuild.sh" switch "$host"
  write_local_config "$repo/hosts/$host/local.nix" "$username" "$network_hostname" "$driver_profile" "$features"
  sudo nixos-rebuild switch --flake ".#$host"
}

run_mounted_install() {
  require_cmd findmnt nixos-generate-config nixos-install sudo

  findmnt /mnt >/dev/null 2>&1 || die "/mnt is not mounted. Mount the target root filesystem first."

  local host network_hostname driver_profile username features
  local secure_boot encryption
  host="$(select_host "$repo")"
  network_hostname="$(select_network_hostname "$host")"
  driver_profile="$(select_driver_profile "$(default_driver_profile "$host")")"
  username="$(prompt_default "NixOS username" "curse")"
  validate_username "$username" || die "Invalid username: $username"
  features="$(select_features)"
  secure_boot="$(select_secure_boot)"
  encryption="none"

  cat <<SUMMARY

Mounted install summary
-----------------------
Flake host:          $host
Networking hostname: $network_hostname
Driver profile:      $driver_profile
Username:            $username
Target:              existing filesystems mounted under /mnt
Features:            $(features_summary "$features")
Security:            $(security_summary "$encryption" "$secure_boot")
Command:             sudo nixos-install --flake .#$host

Files updated before install:
  $repo/hosts/$host/hardware-configuration.nix
  $repo/hosts/$host/local.nix

No partitioning or formatting will be performed by this mode.
Encryption is not configured by mounted install mode; use full-disk install for LUKS setup.
SUMMARY

  confirm_yes_no "Install to the mounted /mnt target?" "n" || die "Install cancelled."
  info "Generating hardware configuration from mounted target"
  nixos-generate-config --root /mnt --show-hardware-config > "$repo/hosts/$host/hardware-configuration.nix"
  write_local_config "$repo/hosts/$host/local.nix" "$username" "$network_hostname" "$driver_profile" "$features" "$encryption" "$secure_boot"
  sudo nixos-install --flake ".#$host"
}

run_full_disk_install() {
  warn "The next workflow can wipe an entire disk, but only after an exact disk-specific confirmation."
  confirm_yes_no "Open the full-disk installer?" "n" || die "Full-disk install cancelled."

  if ((EUID == 0)); then
    "$repo/scripts/full-disk-install.sh"
  else
    sudo --preserve-env=PATH "$repo/scripts/full-disk-install.sh"
  fi
}

main() {
  if (($# > 0)); then
    case "$1" in
      -h|--help) usage; exit 0 ;;
      *) die "Unknown option: $1" ;;
    esac
  fi

  cat <<'MENU'

NixOS repository installer
--------------------------
1) Rebuild this already-installed system
2) Install an existing host to filesystems already mounted at /mnt
3) Full-disk install an existing host, wiping a selected disk
4) Quit
MENU

  local choice
  read -r -p "Choose 1-4: " choice
  case "$choice" in
    1) run_rebuild ;;
    2) run_mounted_install ;;
    3) run_full_disk_install ;;
    4) exit 0 ;;
    *) die "Invalid selection." ;;
  esac
}

main "$@"
