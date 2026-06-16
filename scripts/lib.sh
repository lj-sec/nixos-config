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

host_names() {
  local root="$1"
  find "$root/hosts" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort
}

select_from_list() {
  local prompt="$1"
  shift
  local items=("$@")
  local choice

  ((${#items[@]} > 0)) || die "No choices available for: $prompt"
  printf '%s\n' "$prompt"
  local i
  for i in "${!items[@]}"; do
    printf '  %d) %s\n' "$((i + 1))" "${items[$i]}"
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

  info "Enter a comma-separated feature list, or '__none__' for no optional features."
  info "Available features:"
  local i
  for i in "${!feature_keys[@]}"; do
    printf '  %-15s %s\n' "${feature_keys[$i]}" "${feature_descriptions[$i]}"
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

select_disk() {
  require_cmd lsblk readlink
  mapfile -t disks < <(lsblk -dpno PATH,SIZE,MODEL,SERIAL,TYPE | awk '$NF == "disk" {print}')
  ((${#disks[@]} > 0)) || die "No block disks found."

  printf '%s\n' "Available disks:"
  local i
  for i in "${!disks[@]}"; do
    printf '  %d) %s\n' "$((i + 1))" "${disks[$i]}"
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
