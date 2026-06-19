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
  --network-hostname NAME
                    networking.hostName for the installed system
  --driver-profile PROFILE
                    auto, none, amd, intel, nvidia, or vm
  --username NAME   NixOS user name passed to the flake
  --swap-gib SIZE   Swapfile size in GiB, default 20
  --features CSV    Optional feature CSV, __none__, or empty for defaults
  --encryption MODE none, luks-passphrase, or luks-tpm2
  --secure-boot     Enable Lanzaboote/Secure Boot support
  --no-secure-boot  Disable Lanzaboote/Secure Boot support
  -h, --help        Show this help
USAGE
}

print_finish_instructions() {
  local encryption="$1"
  local secure_boot="$2"
  local luks_device_uuid="$3"

  cat <<SUMMARY

Post-install checklist
----------------------
Before rebooting:
  1. Review the nixos-install output above.
  2. Keep this passphrase available if LUKS encryption was selected.
SUMMARY

  if [[ "$secure_boot" == "true" ]]; then
    cat <<'SUMMARY'

Lanzaboote / Secure Boot:
  1. Before the first boot, make sure firmware Secure Boot is disabled or in
     setup mode. Do not boot with old/vendor-only Secure Boot enforcement.
  2. Boot once into the installed NixOS system.
  3. Enter firmware Secure Boot setup mode. Do not clear the dbx database.
  4. Run:
       sudo sbctl status
       sudo sbctl enroll-keys --microsoft
       sudo sbctl verify
  5. Reboot and confirm:
       bootctl status
     shows Secure Boot enabled in user mode.
SUMMARY
  fi

  if [[ "$encryption" == "luks-tpm2" ]]; then
    cat <<SUMMARY

LUKS TPM2 PCR 7 enrollment:
  Complete the Secure Boot steps first, then run:
       sudo systemd-cryptenroll --wipe-slot=tpm2 --tpm2-device=auto --tpm2-pcrs=7 /dev/disk/by-uuid/$luks_device_uuid

  Reboot once more and confirm the TPM unlock works.
  The original LUKS passphrase remains available as the fallback unlock method.
SUMMARY
  elif [[ "$encryption" == "luks-passphrase" ]]; then
    cat <<'SUMMARY'

LUKS passphrase unlock:
  No TPM enrollment is needed. The installed system will ask for the LUKS
  passphrase at boot.
SUMMARY
  fi
}

create_secure_boot_keys() {
  local sbctl_config
  local -a sbctl_cmd

  if [[ -f /mnt/var/lib/sbctl/keys/db/db.key ]]; then
    ok "Secure Boot keys already exist in /mnt/var/lib/sbctl."
    return
  fi

  if command -v sbctl >/dev/null 2>&1; then
    sbctl_cmd=(sbctl)
  elif command -v nix >/dev/null 2>&1; then
    sbctl_cmd=(nix run --extra-experimental-features nix-command --extra-experimental-features flakes nixpkgs#sbctl --)
  else
    die "Secure Boot key generation requires sbctl or nix."
  fi

  mkdir -p /mnt/var/lib/sbctl
  sbctl_config="$(mktemp /tmp/sbctl-target.XXXXXX.yml)"
  cat > "$sbctl_config" <<'EOF'
---
keydir: /mnt/var/lib/sbctl/keys
guid: /mnt/var/lib/sbctl/GUID
files_db: /mnt/var/lib/sbctl/files.json
bundles_db: /mnt/var/lib/sbctl/bundles.json
landlock: false
EOF

  info "Generating Secure Boot signing keys in /mnt/var/lib/sbctl"
  "${sbctl_cmd[@]}" --config "$sbctl_config" --disable-landlock create-keys --database-path /mnt/var/lib/sbctl/GUID \
    || die "Could not generate Secure Boot keys. Lanzaboote installs require keys before nixos-install."
  ok "Generated Secure Boot keys in /mnt/var/lib/sbctl."
}

repo="$(repo_root)"
host=""
disk=""
network_hostname=""
driver_profile=""
username=""
swap_gib="20"
features=""
encryption=""
secure_boot=""
luks_name="cryptroot"
tpm2_pcrs="7"

while (($# > 0)); do
  case "$1" in
    --host) host="${2:-}"; shift 2 ;;
    --disk) disk="${2:-}"; shift 2 ;;
    --network-hostname) network_hostname="${2:-}"; shift 2 ;;
    --driver-profile) driver_profile="${2:-}"; shift 2 ;;
    --username) username="${2:-}"; shift 2 ;;
    --swap-gib) swap_gib="${2:-}"; shift 2 ;;
    --features) features="${2:-}"; shift 2 ;;
    --encryption) encryption="${2:-}"; shift 2 ;;
    --secure-boot) secure_boot="true"; shift ;;
    --no-secure-boot) secure_boot="false"; shift ;;
    -h|--help) usage; exit 0 ;;
    *) die "Unknown option: $1" ;;
  esac
done

((EUID == 0)) || die "Run this script as root from the NixOS installer environment."

require_cmd awk blkid btrfs cryptsetup findmnt lsblk mkfs.btrfs mkfs.fat mount nixos-generate-config nixos-install partprobe readlink sgdisk udevadm umount

cd "$repo"

if [[ -z "$host" ]]; then
  host="$(select_host "$repo")"
fi
[[ -d "$repo/hosts/$host" ]] || die "Unknown host: $host"

if [[ -z "$network_hostname" ]]; then
  network_hostname="$(select_network_hostname "$host")"
fi
validate_hostname "$network_hostname" || die "Invalid networking hostname: $network_hostname"

if [[ -z "$driver_profile" ]]; then
  driver_profile="$(select_driver_profile "$(default_driver_profile "$host")")"
fi
validate_driver_profile "$driver_profile" || die "Invalid driver profile: $driver_profile"

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

if [[ -z "$secure_boot" ]]; then
  secure_boot="$(select_secure_boot)"
fi
validate_bool "$secure_boot" || die "Invalid secure boot setting: $secure_boot"

if [[ -z "$encryption" ]]; then
  encryption="$(select_encryption_mode)"
fi
validate_encryption_mode "$encryption" || die "Invalid encryption mode: $encryption"
if [[ "$encryption" == "luks-tpm2" && "$secure_boot" != "true" ]]; then
  die "luks-tpm2 requires Lanzaboote/Secure Boot support. Re-run with --secure-boot or choose luks-passphrase."
fi

efi_part="$(partition_path "$disk" 1)"
root_part="$(partition_path "$disk" 2)"
root_fs_device="$root_part"
luks_device_uuid=""
root_partition_description="remaining disk, Btrfs label NIXOS"
if [[ "$encryption" != "none" ]]; then
  root_fs_device="/dev/mapper/$luks_name"
  root_partition_description="remaining disk, LUKS container for Btrfs label NIXOS"
fi

cat <<SUMMARY

Full-disk NixOS install summary
--------------------------------
Host:          $host
Hostname:      $network_hostname
Driver:        $driver_profile
Source repo:    $repo
Install repo:   /mnt/etc/nixos
Username:      $username
Target disk:   $disk
EFI partition: $efi_part  (1 GiB, FAT32 label BOOT)
Root partition: $root_part  ($root_partition_description)
Subvolumes:    @, @home, @nix, @log, @snapshots
Swapfile:      /var/lib/swap/swapfile (${swap_gib} GiB)
Features:      $(features_summary "$features")
Security:      $(security_summary "$encryption" "$secure_boot")

Files updated in the installed system repo before install:
  /mnt/etc/nixos/hosts/$host/local.nix
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
if [[ "$encryption" == "none" ]]; then
  sgdisk -n 2:0:0 -t 2:8300 -c 2:NIXOS "$disk"
else
  sgdisk -n 2:0:0 -t 2:8309 -c 2:CRYPTROOT "$disk"
fi
partprobe "$disk"
udevadm settle

info "Formatting filesystems"
mkfs.fat -F 32 -n BOOT "$efi_part"
if [[ "$encryption" == "none" ]]; then
  mkfs.btrfs -f -L NIXOS "$root_fs_device"
else
  info "Creating LUKS container. You will be prompted for the fallback boot passphrase."
  cryptsetup luksFormat "$root_part"
  luks_device_uuid="$(blkid -s UUID -o value "$root_part")"
  info "Opening LUKS container as $luks_name"
  cryptsetup open "$root_part" "$luks_name"
  mkfs.btrfs -f -L NIXOS "$root_fs_device"
fi

info "Creating Btrfs subvolumes"
mount "$root_fs_device" /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@nix
btrfs subvolume create /mnt/@log
btrfs subvolume create /mnt/@snapshots
umount /mnt

info "Mounting target filesystems"
mount -o subvol=@ "$root_fs_device" /mnt
mkdir -p /mnt/{boot,home,nix,var/log,.snapshots}
mount -o subvol=@home "$root_fs_device" /mnt/home
mount -o subvol=@nix "$root_fs_device" /mnt/nix
mount -o subvol=@log "$root_fs_device" /mnt/var/log
mount -o subvol=@snapshots "$root_fs_device" /mnt/.snapshots
mount "$efi_part" /mnt/boot

info "Creating Btrfs-safe swapfile"
mkdir -p /mnt/var/lib/swap
btrfs filesystem mkswapfile --size "${swap_mib}M" --uuid clear /mnt/var/lib/swap/swapfile
resume_offset="$(btrfs inspect-internal map-swapfile -r /mnt/var/lib/swap/swapfile)"
root_uuid="$(blkid -s UUID -o value "$root_fs_device")"

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
write_local_config \
  "$install_repo/hosts/$host/local.nix" \
  "$username" \
  "$network_hostname" \
  "$driver_profile" \
  "$features" \
  "$encryption" \
  "$secure_boot" \
  "$luks_device_uuid" \
  "$luks_name" \
  "$tpm2_pcrs"

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
if [[ "$secure_boot" == "true" ]]; then
  create_secure_boot_keys
fi

info "Installing NixOS. You may be prompted for passwords by nixos-install."
nixos-install --flake "$install_repo#$host"

ok "Install finished. Review the output above before rebooting."
print_finish_instructions "$encryption" "$secure_boot" "$luks_device_uuid"
