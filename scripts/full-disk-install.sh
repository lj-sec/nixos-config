#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib.sh
source "$script_dir/lib.sh"

usage() {
  cat <<'USAGE'
Usage: sudo scripts/full-disk-install.sh [options]

This script intentionally wipes one selected whole disk and installs NixOS.
It never runs unless you confirm the exact disk-specific wipe phrase.

Options:
  --host NAME       Existing flake host to install
  --disk PATH       Whole target disk, e.g. /dev/nvme0n1
  --username NAME   NixOS user name passed to the flake
  --swap-gib SIZE   Swapfile size in GiB, default 20
  --features CSV    Optional feature CSV, __none__, or empty for defaults
  -h, --help        Show this help
USAGE
}

repo="$(repo_root)"
host=""
disk=""
username=""
swap_gib="20"
features=""

while (($# > 0)); do
  case "$1" in
    --host) host="${2:-}"; shift 2 ;;
    --disk) disk="${2:-}"; shift 2 ;;
    --username) username="${2:-}"; shift 2 ;;
    --swap-gib) swap_gib="${2:-}"; shift 2 ;;
    --features) features="${2:-}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) die "Unknown option: $1" ;;
  esac
done

((EUID == 0)) || die "Run this script as root from the NixOS installer environment."

require_cmd awk blkid btrfs findmnt lsblk mkfs.btrfs mkfs.fat mount nixos-generate-config nixos-install partprobe readlink sgdisk udevadm umount

cd "$repo"

if [[ -z "$host" ]]; then
  host="$(select_host "$repo")"
fi
[[ -d "$repo/hosts/$host" ]] || die "Unknown host: $host"

if [[ -z "$username" ]]; then
  username="$(prompt_default "NixOS username" "curse")"
fi
validate_username "$username" || die "Invalid username: $username"

if [[ -z "$disk" ]]; then
  disk="$(select_disk)"
else
  disk="$(readlink -f "$disk")"
fi
[[ -b "$disk" ]] || die "Target disk is not a block device: $disk"
[[ "$(lsblk -dn -o TYPE "$disk")" == "disk" ]] || die "Target is not a whole disk: $disk"

validate_swap_gib "$swap_gib" || die "Swap size must be a positive integer."
swap_mib=$((swap_gib * 1024))

if [[ -z "$features" ]]; then
  features="$(select_features)"
fi

efi_part="$(partition_path "$disk" 1)"
root_part="$(partition_path "$disk" 2)"

cat <<SUMMARY

Full-disk NixOS install summary
--------------------------------
Host:          $host
Source repo:    $repo
Install repo:   /mnt/etc/nixos
Username:      $username
Target disk:   $disk
EFI partition: $efi_part  (1 GiB, FAT32 label BOOT)
Root partition: $root_part  (remaining disk, Btrfs label NIXOS)
Subvolumes:    @, @home, @nix, @log, @snapshots
Swapfile:      /var/lib/swap/swapfile (${swap_gib} GiB)
Features:      $(features_summary "$features")

Files updated in the installed system repo before install:
  /mnt/etc/nixos/hosts/$host/hardware-configuration.nix
  /mnt/etc/nixos/hosts/$host/swap.nix

THIS WILL DESTROY ALL DATA ON $disk.
SUMMARY

confirm_phrase "WIPE $disk" || die "Disk wipe was not confirmed."

if findmnt -R /mnt >/dev/null 2>&1; then
  warn "/mnt already has mounted filesystems. They will be unmounted before partitioning."
  findmnt -R /mnt
  confirm_phrase "UNMOUNT /mnt" || die "Refusing to continue with /mnt mounted."
  umount -R /mnt
fi

info "Partitioning $disk"
sgdisk --zap-all "$disk"
sgdisk -n 1:1MiB:+1GiB -t 1:EF00 -c 1:BOOT "$disk"
sgdisk -n 2:0:0 -t 2:8300 -c 2:NIXOS "$disk"
partprobe "$disk"
udevadm settle

info "Formatting filesystems"
mkfs.fat -F 32 -n BOOT "$efi_part"
mkfs.btrfs -f -L NIXOS "$root_part"

info "Creating Btrfs subvolumes"
mount "$root_part" /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@nix
btrfs subvolume create /mnt/@log
btrfs subvolume create /mnt/@snapshots
umount /mnt

info "Mounting target filesystems"
mount -o subvol=@ "$root_part" /mnt
mkdir -p /mnt/{boot,home,nix,var/log,.snapshots}
mount -o subvol=@home "$root_part" /mnt/home
mount -o subvol=@nix "$root_part" /mnt/nix
mount -o subvol=@log "$root_part" /mnt/var/log
mount -o subvol=@snapshots "$root_part" /mnt/.snapshots
mount "$efi_part" /mnt/boot

info "Creating Btrfs-safe swapfile"
mkdir -p /mnt/var/lib/swap
btrfs filesystem mkswapfile --size "${swap_mib}M" --uuid clear /mnt/var/lib/swap/swapfile
resume_offset="$(btrfs inspect-internal map-swapfile -r /mnt/var/lib/swap/swapfile)"
root_uuid="$(blkid -s UUID -o value "$root_part")"

install_repo="/mnt/etc/nixos"
repo_real="$(readlink -f "$repo")"
install_repo_real="$(readlink -m "$install_repo")"
if [[ "$repo_real" == "$install_repo_real" ]]; then
  info "Using repository already located at $install_repo."
else
  info "Copying repository to $install_repo so generated install files persist after reboot"
  mkdir -p "$install_repo"
  cp -a "$repo/." "$install_repo/"
fi

info "Generating hardware configuration"
nixos-generate-config --root /mnt --show-hardware-config > "$install_repo/hosts/$host/hardware-configuration.nix"

cat > "$install_repo/hosts/$host/swap.nix" <<EOF
{ ... }:
{
  boot = {
    kernelParams = [
      "resume_offset=$resume_offset"
    ];
    resumeDevice = "/dev/disk/by-uuid/$root_uuid";
  };

  swapDevices = [
    {
      device = "/var/lib/swap/swapfile";
      size = $swap_mib;
    }
  ];
}
EOF

ok "Updated hardware and swap configuration for $host."
info "Installing NixOS. You may be prompted for passwords by nixos-install."
env NIXOS_CONFIG_USERNAME="$username" NIXOS_CONFIG_FEATURES="$features" \
  nixos-install --flake "$install_repo#$host" --impure

ok "Install finished. Review the output above before rebooting."
