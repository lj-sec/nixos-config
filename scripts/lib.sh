#!/usr/bin/env bash

set -euo pipefail

repo_root() {
  local script_dir
  script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
  cd -- "$script_dir/.." && pwd
}

is_tty() {
  [[ -t 1 ]]
}

if is_tty; then
  reset="$(tput sgr0 2>/dev/null || true)"
  red="$(tput setaf 1 2>/dev/null || true)"
  green="$(tput setaf 2 2>/dev/null || true)"
  yellow="$(tput setaf 3 2>/dev/null || true)"
  blue="$(tput setaf 4 2>/dev/null || true)"
else
  reset=""
  red=""
  green=""
  yellow=""
  blue=""
fi

info() { printf '%b\n' "${blue}INFO${reset} $*"; }
ok() { printf '%b\n' "${green}OK${reset} $*"; }
warn() { printf '%b\n' "${yellow}WARN${reset} $*"; }
die() {
  printf '%b\n' "${red}ERROR${reset} $*" >&2
  exit 1
}

require_cmd() {
  local missing=()
  local cmd
  for cmd in "$@"; do
    command -v "$cmd" >/dev/null 2>&1 || missing+=("$cmd")
  done

  if ((${#missing[@]} > 0)); then
    die "Missing required command(s): ${missing[*]}"
  fi
}

prompt_default() {
  local prompt="$1"
  local default="$2"
  local answer

  read -r -p "$prompt [$default]: " answer
  printf '%s\n' "${answer:-$default}"
}

prompt_required() {
  local prompt="$1"
  local answer

  while true; do
    read -r -p "$prompt: " answer
    [[ -n "$answer" ]] && {
      printf '%s\n' "$answer"
      return
    }
    warn "This value is required."
  done
}

confirm_yes_no() {
  local prompt="$1"
  local default="${2:-n}"
  local suffix="[y/N]"
  local answer

  [[ "$default" == "y" ]] && suffix="[Y/n]"
  read -r -p "$prompt $suffix " answer
  answer="${answer:-$default}"
  [[ "$answer" =~ ^[Yy]$ ]]
}

confirm_phrase() {
  local phrase="$1"
  local answer

  warn "Type exactly '$phrase' to continue."
  read -r -p "> " answer
  [[ "$answer" == "$phrase" ]]
}

join_by() {
  local sep="$1"
  shift || true

  local out=""
  local item
  for item in "$@"; do
    [[ -n "$out" ]] && out+="$sep"
    out+="$item"
  done

  printf '%s' "$out"
}

validate_hostname() {
  local host="$1"
  [[ "$host" =~ ^[a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?$ ]]
}

validate_username() {
  local username="$1"
  [[ "$username" =~ ^[a-z][a-z0-9_-]{0,31}$ ]]
}

validate_arch() {
  local arch="$1"
  [[ "$arch" == "x86_64-linux" || "$arch" == "aarch64-linux" ]]
}

validate_swap_gib() {
  local size="$1"
  [[ "$size" =~ ^[1-9][0-9]*$ ]]
}

encryption_modes=(none luks-passphrase luks-tpm2)

encryption_mode_descriptions=(
  "Plain Btrfs root with no disk encryption"
  "LUKS encrypted root unlocked with a boot passphrase"
  "LUKS encrypted root with TPM2 PCR 7 unlock and passphrase fallback"
)

validate_encryption_mode() {
  local mode="$1"
  local known_mode

  for known_mode in "${encryption_modes[@]}"; do
    [[ "$mode" == "$known_mode" ]] && return 0
  done

  return 1
}

select_encryption_mode() {
  local mode i

  info "Available encryption modes:" >&2
  for i in "${!encryption_modes[@]}"; do
    printf '  %-16s %s\n' "${encryption_modes[$i]}" "${encryption_mode_descriptions[$i]}" >&2
  done

  while true; do
    mode="$(prompt_default "Encryption mode" "none")"
    if validate_encryption_mode "$mode"; then
      printf '%s\n' "$mode"
      return
    fi
    warn "Unknown encryption mode: $mode"
  done
}

select_secure_boot() {
  if confirm_yes_no "Enable Lanzaboote/Secure Boot support for this install?" "n"; then
    printf '%s\n' "true"
  else
    printf '%s\n' "false"
  fi
}

validate_bool() {
  local value="$1"
  [[ "$value" == "true" || "$value" == "false" ]]
}

security_summary() {
  local encryption="$1"
  local secure_boot="$2"

  printf 'encryption=%s, lanzaboote=%s\n' "$encryption" "$secure_boot"
}

driver_profiles=(auto none amd intel nvidia vm)

driver_profile_descriptions=(
  "Use NixOS defaults without forcing a display driver"
  "Disable explicit graphics driver configuration"
  "AMDGPU driver for Ryzen/Radeon systems"
  "Modesetting driver for Intel graphics"
  "NVIDIA proprietary driver"
  "VirtIO/QEMU guest profile for virtual machines"
)

validate_driver_profile() {
  local profile="$1"
  local known_profile

  for known_profile in "${driver_profiles[@]}"; do
    [[ "$profile" == "$known_profile" ]] && return 0
  done

  return 1
}

default_driver_profile() {
  local host="$1"

  case "$host" in
    desktop) printf '%s\n' "nvidia" ;;
    laptop) printf '%s\n' "amd" ;;
    server) printf '%s\n' "none" ;;
    vm) printf '%s\n' "vm" ;;
    *) printf '%s\n' "auto" ;;
  esac
}

select_driver_profile() {
  local default="$1"
  local profile i

  info "Available driver profiles:" >&2
  for i in "${!driver_profiles[@]}"; do
    printf '  %-8s %s\n' "${driver_profiles[$i]}" "${driver_profile_descriptions[$i]}" >&2
  done

  while true; do
    profile="$(prompt_default "Driver profile" "$default")"
    if validate_driver_profile "$profile"; then
      printf '%s\n' "$profile"
      return
    fi
    warn "Unknown driver profile: $profile"
  done
}

select_network_hostname() {
  local default="$1"
  local hostname

  while true; do
    hostname="$(prompt_default "Networking hostname" "$default")"
    if validate_hostname "$hostname"; then
      printf '%s\n' "$hostname"
      return
    fi
    warn "Use lowercase letters, numbers, and hyphens only."
  done
}

host_names() {
  printf '%s\n' desktop laptop server vm
}

select_from_list() {
  local prompt="$1"
  shift
  local items=("$@")
  local choice

  ((${#items[@]} > 0)) || die "No choices available for: $prompt"
  printf '%s\n' "$prompt" >&2
  local i
  for i in "${!items[@]}"; do
    printf '  %d) %s\n' "$((i + 1))" "${items[$i]}" >&2
  done

  while true; do
    read -r -p "Choose 1-${#items[@]}: " choice
    if [[ "$choice" =~ ^[0-9]+$ ]] && ((choice >= 1 && choice <= ${#items[@]})); then
      printf '%s\n' "${items[$((choice - 1))]}"
      return
    fi
    warn "Invalid selection."
  done
}

select_host() {
  local root="$1"
  mapfile -t hosts < <(host_names "$root")
  select_from_list "Select a host:" "${hosts[@]}"
}

feature_keys=(
  brave btrfsScrub vscode pass communication mail media music office fun
  security devops remote steam virtualization kali networkExtras syncthing
  proxy printing bluetooth phones flatpak power ssh
)

feature_descriptions=(
  "Brave browser and browser defaults"
  "Weekly Btrfs scrub for /"
  "VSCodium settings and extensions"
  "pass, GPG, and password-store config"
  "Vesktop, Signal, and Slack"
  "Thunderbird mail client"
  "Creative/media tools"
  "Spotify and Waybar lyrics integration"
  "Calendar, Obsidian, LibreOffice, and spellcheck"
  "Novelty CLI tools and Prism Launcher"
  "Recon/security tools"
  "Terraform, Ansible, PowerShell, WinRM, and linting"
  "VPN, FileZilla, Remmina, and Raspberry Pi Imager"
  "Steam, Gamescope, Proton-GE, and xone controller support"
  "Libvirt, virt-manager, SPICE, and full VM support"
  "Kali distrobox packages and bootstrap service"
  "Tailscale, GlobalProtect, and Wireshark"
  "Syncthing service"
  "Shadowsocks client and proxychains"
  "Printing and Avahi discovery"
  "Bluetooth and Blueman"
  "iPhone/USB phone storage support"
  "Flatpak service"
  "cpupower and suspend-then-hibernate policy"
  "OpenSSH daemon with firewall kept closed"
)

select_features() {
  local selected=()
  local csv

  if confirm_yes_no "Use the default optional feature set?" "y"; then
    join_by "," "${feature_keys[@]}"
    return
  fi

  info "Enter a comma-separated feature list, or '__none__' for no optional features." >&2
  info "Available features:" >&2
  local i
  for i in "${!feature_keys[@]}"; do
    printf '  %-15s %s\n' "${feature_keys[$i]}" "${feature_descriptions[$i]}" >&2
  done

  csv="$(prompt_default "Features" "__none__")"
  if [[ "$csv" == "__none__" || -z "$csv" ]]; then
    printf '%s\n' "__none__"
    return
  fi

  IFS=',' read -r -a selected <<< "$csv"
  local feature known known_feature
  for feature in "${selected[@]}"; do
    feature="${feature//[[:space:]]/}"
    known=0
    for known_feature in "${feature_keys[@]}"; do
      if [[ "$feature" == "$known_feature" ]]; then
        known=1
        break
      fi
    done
    ((known)) || die "Unknown feature: $feature"
  done

  printf '%s\n' "$csv"
}

features_summary() {
  local features="$1"
  if [[ -z "$features" ]]; then
    printf '%s\n' "default optional feature set"
  elif [[ "$features" == "__none__" ]]; then
    printf '%s\n' "no optional features"
  else
    printf '%s\n' "$features"
  fi
}

feature_selected() {
  local features="$1"
  local wanted="$2"
  local feature
  local selected_features

  [[ "$features" != "__none__" ]] || return 1
  [[ -n "$features" ]] || return 0

  IFS=',' read -r -a selected_features <<< "$features"
  for feature in "${selected_features[@]}"; do
    feature="${feature//[[:space:]]/}"
    [[ "$feature" == "$wanted" ]] && return 0
  done

  return 1
}

write_local_config() {
  local file="$1"
  local username="$2"
  local network_hostname="$3"
  local driver_profile="$4"
  local features="$5"
  local encryption="${6:-none}"
  local secure_boot="${7:-false}"
  local luks_device_uuid="${8:-}"
  local luks_name="${9:-cryptroot}"
  local tpm2_pcrs="${10:-7}"
  local security_supplied=0
  local existing_security=""
  local luks_device_uuid_nix="null"
  local feature enabled

  validate_username "$username" || die "Invalid username: $username"
  validate_hostname "$network_hostname" || die "Invalid networking hostname: $network_hostname"
  validate_driver_profile "$driver_profile" || die "Invalid driver profile: $driver_profile"

  if (($# >= 7)); then
    security_supplied=1
    validate_encryption_mode "$encryption" || die "Invalid encryption mode: $encryption"
    validate_bool "$secure_boot" || die "Invalid secure boot setting: $secure_boot"
    if [[ -n "$luks_device_uuid" ]]; then
      luks_device_uuid_nix="\"$luks_device_uuid\""
    fi
  elif [[ -f "$file" ]]; then
    existing_security="$(awk '
      /^  installSecurity = \{/ { in_block = 1 }
      in_block { print }
      in_block && /^  \};/ { exit }
    ' "$file")"
  fi

  {
    cat <<EOF
{
  username = "$username";
  networkingHostName = "$network_hostname";
  driverProfile = "$driver_profile";
EOF

    if ((security_supplied)); then
      cat <<EOF
  installSecurity = {
    encryption = "$encryption";
    secureBoot = $secure_boot;
    luksName = "$luks_name";
    luksDeviceUuid = $luks_device_uuid_nix;
    tpm2Pcrs = [ $tpm2_pcrs ];
  };
EOF
    elif [[ -n "$existing_security" ]]; then
      printf '%s\n' "$existing_security"
    fi

    cat <<'EOF'
  installFeatures = {
EOF

    for feature in "${feature_keys[@]}"; do
      enabled="false"
      if feature_selected "$features" "$feature"; then
        enabled="true"
      fi
      printf '      %s = %s;\n' "$feature" "$enabled"
    done

    cat <<'EOF'
  };
}
EOF
  } > "$file"
}

select_disk() {
  require_cmd lsblk readlink
  mapfile -t disks < <(lsblk -dpno PATH,SIZE,MODEL,SERIAL,TYPE | awk '$NF == "disk" {print}')
  ((${#disks[@]} > 0)) || die "No block disks found."

  printf '%s\n' "Available disks:" >&2
  local i
  for i in "${!disks[@]}"; do
    printf '  %d) %s\n' "$((i + 1))" "${disks[$i]}" >&2
  done

  local choice disk type
  while true; do
    read -r -p "Choose target disk 1-${#disks[@]}: " choice
    if [[ "$choice" =~ ^[0-9]+$ ]] && ((choice >= 1 && choice <= ${#disks[@]})); then
      disk="$(awk '{print $1}' <<< "${disks[$((choice - 1))]}")"
      disk="$(readlink -f "$disk")"
      type="$(lsblk -dn -o TYPE "$disk")"
      [[ "$type" == "disk" ]] || die "$disk is not a whole disk."
      printf '%s\n' "$disk"
      return
    fi
    warn "Invalid selection."
  done
}

partition_path() {
  local disk="$1"
  local part="$2"

  if [[ "$disk" =~ [0-9]$ ]]; then
    printf '%sp%s\n' "$disk" "$part"
  else
    printf '%s%s\n' "$disk" "$part"
  fi
}
