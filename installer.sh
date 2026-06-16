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
  4. generating a new host scaffold
USAGE
}

run_rebuild() {
  require_cmd nixos-rebuild sudo

  local host username features
  host="$(select_host "$repo")"
  username="$(prompt_default "NixOS username" "${USER:-curse}")"
  validate_username "$username" || die "Invalid username: $username"
  features="$(select_features)"

  cat <<SUMMARY

Rebuild summary
---------------
Host:     $host
Username: $username
Features: $(features_summary "$features")
Command:  sudo nixos-rebuild switch --impure --flake .#$host
SUMMARY

  confirm_yes_no "Run this rebuild?" "n" || die "Rebuild cancelled."
  sudo env NIXOS_CONFIG_USERNAME="$username" NIXOS_CONFIG_FEATURES="$features" \
    nixos-rebuild switch --impure --flake ".#$host"
}

run_mounted_install() {
  require_cmd findmnt nixos-install sudo

  findmnt /mnt >/dev/null 2>&1 || die "/mnt is not mounted. Mount the target root filesystem first."

  local host username features
  host="$(select_host "$repo")"
  username="$(prompt_default "NixOS username" "curse")"
  validate_username "$username" || die "Invalid username: $username"
  features="$(select_features)"

  cat <<SUMMARY

Mounted install summary
-----------------------
Host:      $host
Username:  $username
Target:    existing filesystems mounted under /mnt
Features:  $(features_summary "$features")
Command:   sudo nixos-install --flake .#$host --impure

No partitioning or formatting will be performed by this mode.
SUMMARY

  confirm_yes_no "Install to the mounted /mnt target?" "n" || die "Install cancelled."
  sudo env NIXOS_CONFIG_USERNAME="$username" NIXOS_CONFIG_FEATURES="$features" \
    nixos-install --flake ".#$host" --impure
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

run_new_host() {
  "$repo/scripts/new-host.sh"
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
4) Generate a new host scaffold
5) Quit
MENU

  local choice
  read -r -p "Choose 1-5: " choice
  case "$choice" in
    1) run_rebuild ;;
    2) run_mounted_install ;;
    3) run_full_disk_install ;;
    4) run_new_host ;;
    5) exit 0 ;;
    *) die "Invalid selection." ;;
  esac
}

main "$@"
