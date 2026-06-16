#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib.sh
source "$script_dir/lib.sh"

usage() {
  cat <<'USAGE'
Usage: scripts/new-host.sh [options]

Options:
  --host NAME            Hostname/flake output to create
  --arch SYSTEM          Nix system, default x86_64-linux
  --profile TYPE         laptop, desktop, or server
  --swap-gib SIZE        Swapfile size in GiB
  --fingerprint yes|no   Enable fingerprint auth metadata
  --disk-mode MODE       deferred or full-disk
  --target-disk PATH     Optional install note for the intended disk
  --force                Allow overwriting an existing host after confirmation
  -h, --help             Show this help
USAGE
}

repo="$(repo_root)"
host=""
arch="x86_64-linux"
profile="laptop"
swap_gib="20"
fingerprint=""
disk_mode="deferred"
target_disk=""
force=0

while (($# > 0)); do
  case "$1" in
    --host) host="${2:-}"; shift 2 ;;
    --arch) arch="${2:-}"; shift 2 ;;
    --profile) profile="${2:-}"; shift 2 ;;
    --swap-gib) swap_gib="${2:-}"; shift 2 ;;
    --fingerprint) fingerprint="${2:-}"; shift 2 ;;
    --disk-mode) disk_mode="${2:-}"; shift 2 ;;
    --target-disk) target_disk="${2:-}"; shift 2 ;;
    --force) force=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) die "Unknown option: $1" ;;
  esac
done

cd "$repo"

if [[ -z "$host" ]]; then
  while true; do
    host="$(prompt_required "New host name")"
    validate_hostname "$host" && break
    warn "Use lowercase letters, numbers, and hyphens only."
  done
fi
validate_hostname "$host" || die "Invalid host name: $host"

if [[ -z "$arch" ]]; then
  arch="$(prompt_default "System architecture" "x86_64-linux")"
fi
validate_arch "$arch" || die "Unsupported architecture: $arch"

if [[ -z "$profile" ]]; then
  profile="$(select_from_list "Host profile:" laptop desktop server)"
fi
case "$profile" in
  laptop|desktop|server) ;;
  *) die "Profile must be laptop, desktop, or server." ;;
esac

if [[ -z "$swap_gib" ]]; then
  swap_gib="$(prompt_default "Swapfile size in GiB" "20")"
fi
validate_swap_gib "$swap_gib" || die "Swap size must be a positive integer."
swap_mib=$((swap_gib * 1024))

if [[ -z "$fingerprint" ]]; then
  if [[ "$profile" == "laptop" ]] && confirm_yes_no "Enable fingerprint auth metadata?" "y"; then
    fingerprint="yes"
  else
    fingerprint="no"
  fi
fi
case "$fingerprint" in
  yes) has_fingerprint="true" ;;
  no) has_fingerprint="false" ;;
  *) die "--fingerprint must be yes or no." ;;
esac

if [[ -z "$disk_mode" ]]; then
  disk_mode="$(select_from_list "Disk config mode:" deferred full-disk)"
fi
case "$disk_mode" in
  deferred|full-disk) ;;
  *) die "--disk-mode must be deferred or full-disk." ;;
esac

if [[ "$disk_mode" == "full-disk" && -z "$target_disk" ]]; then
  target_disk="$(prompt_default "Intended target disk note" "select-during-install")"
fi

host_dir="$repo/hosts/$host"
if [[ -e "$host_dir" ]]; then
  ((force)) || die "Host already exists: $host"
  confirm_phrase "OVERWRITE $host" || die "Refusing to overwrite $host."
fi

mkdir -p "$host_dir"

target_disk_literal="null"
if [[ -n "$target_disk" && "$target_disk" != "select-during-install" ]]; then
  escaped_target_disk="${target_disk//\\/\\\\}"
  escaped_target_disk="${escaped_target_disk//\"/\\\"}"
  target_disk_literal="\"$escaped_target_disk\""
fi

cat > "$host_dir/meta.nix" <<EOF
{
  system = "$arch";
  profile = "$profile";
  hasFingerprint = $has_fingerprint;

  install = {
    diskMode = "$disk_mode";
    targetDisk = $target_disk_literal;
    swapSizeGiB = $swap_gib;
  };
}
EOF

cat > "$host_dir/default.nix" <<'EOF'
{ pkgs, lib, hostProfile ? "desktop", ... }:
{
  imports = [
    ./swap.nix
    ./hardware-configuration.nix
    ./../../modules/core
  ];

  hardware.enableRedistributableFirmware = lib.mkDefault true;

  environment.systemPackages =
    lib.optionals (hostProfile == "laptop") (with pkgs; [
      acpi
      brightnessctl
      powertop
    ]);
}
EOF

cat > "$host_dir/hardware-configuration.nix" <<EOF
# Generated host scaffold.
# Review this after installing or replace it with:
#   sudo nixos-generate-config --show-hardware-config --root /mnt > hosts/$host/hardware-configuration.nix
{ config, lib, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXOS";
    fsType = "btrfs";
    options = [ "subvol=@" ];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-label/NIXOS";
    fsType = "btrfs";
    options = [ "subvol=@home" ];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-label/NIXOS";
    fsType = "btrfs";
    options = [ "subvol=@nix" ];
  };

  fileSystems."/var/log" = {
    device = "/dev/disk/by-label/NIXOS";
    fsType = "btrfs";
    options = [ "subvol=@log" ];
  };

  fileSystems."/.snapshots" = {
    device = "/dev/disk/by-label/NIXOS";
    fsType = "btrfs";
    options = [ "subvol=@snapshots" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/BOOT";
    fsType = "vfat";
    options = [ "fmask=0022" "dmask=0022" ];
  };

  swapDevices = [ ];

  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "$arch";
}
EOF

cat > "$host_dir/swap.nix" <<EOF
{ ... }:
{
  # NixOS creates this Btrfs-safe swapfile with btrfs filesystem mkswapfile.
  # For hibernation, run scripts/full-disk-install.sh or record a fresh
  # resume_offset from:
  #   sudo btrfs inspect-internal map-swapfile -r /var/lib/swap/swapfile
  swapDevices = [
    {
      device = "/var/lib/swap/swapfile";
      size = $swap_mib;
    }
  ];
}
EOF

ok "Created host scaffold: hosts/$host"
if command -v git >/dev/null 2>&1 && git -C "$repo" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git -C "$repo" add "$host_dir"
  ok "Staged hosts/$host so Nix flakes can see .#${host} immediately."
else
  warn "This is not a Git checkout; add hosts/$host to version control before building it as a Git flake."
fi
warn "Review hosts/$host/hardware-configuration.nix on real hardware before relying on it."
