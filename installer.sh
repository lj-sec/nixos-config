#!/usr/bin/env bash
set -euo pipefail

echo() { command echo -e "$@"; }

# avoids tput errors if TERM is weird
tput_safe() { tput "$@" 2>/dev/null || true; }

reset="$(tput_safe sgr0)"
red="$(tput_safe setaf 1)"
green="$(tput_safe setaf 2)"
yellow="$(tput_safe setaf 3)"
blue="$(tput_safe setaf 4)"

ok="[${green}OK${reset}]\t"
info="[${blue}INFO${reset}]\t"
error="[${red}ERROR${reset}]\t"

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$script_dir"

join_by() {
  local sep="$1"
  shift || true

  local out=""
  local item
  for item in "$@"; do
    if [[ -n $out ]]; then
      out+="$sep"
    fi
    out+="$item"
  done

  printf '%s' "$out"
}

if [[ $EUID -eq 0 ]]; then
  echo "${error}Do ${red}not${reset} run as root!"
  echo "${info}Exiting..."
  exit 1
fi

# Re-exec inside a nix shell that provides whiptail if missing
if ! command -v whiptail >/dev/null 2>&1; then
  exec nix --extra-experimental-features nix-command --quiet \
       shell nixpkgs#newt -c "$0" "$@"
fi

whiptail --msgbox "Warning: This installer is in an extremely early state, recommend to install manually!" 8 50 --title "Warning"

# Username
while true; do
  username=$(whiptail --inputbox "Enter your username:" 9 40 --title "Username" 3>&1 1>&2 2>&3) || exit 1

  if [[ ! $username =~ ^[a-z][a-z0-9_-]{0,31}$ ]]; then
    whiptail --msgbox "Invalid username: '$username'" 8 50 --title "Error"
    continue
  fi

  if getent passwd "$username" >/dev/null; then
    whiptail --msgbox "User '$username' already exists." 8 50 --title "Error"
    continue
  fi

  if whiptail --yesno "Use '$username' as username?" 8 40 --title "Confirm Username"; then
    break
  fi
done

# Host
base_dir="./hosts"

mapfile -t names < <(find "$base_dir" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort)

args=()
first=1
for name in "${names[@]}"; do
  d="$base_dir/$name"
  status="OFF"
  if (( first )); then status="ON"; first=0; fi
  args+=("$name" "$d" "$status")
done

if ((${#args[@]} == 0)); then
  echo "No directories found under: $base_dir" >&2
  exit 1
fi

while true; do
  host=$(whiptail --title "Choose a host:" --radiolist "Pick one:" 20 80 10 "${args[@]}" 3>&1 1>&2 2>&3 ) || exit 1

  if [[ ! -d "$base_dir/$host" ]]; then
    whiptail --title "Missing host" --msgbox "Directory no longer exists: $base_dir/$host" 8 60
    continue
  fi

  break
done

# Optional components
feature_args=(
  "brave" "Brave browser and browser defaults" "ON"
  "btrfsScrub" "Weekly Btrfs scrub for /" "ON"
  "vscode" "VSCodium settings and extensions" "ON"
  "pass" "pass, GPG, and password-store config" "ON"
  "communication" "Vesktop, Signal, and Slack" "ON"
  "mail" "Thunderbird mail client" "ON"
  "media" "Creative/media tools: GIMP, HandBrake, OBS, mpv, imv" "ON"
  "music" "Spotify and Waybar lyrics integration" "ON"
  "office" "Calendar, Obsidian, LibreOffice, and spellcheck" "ON"
  "fun" "Novelty CLI tools, Minesweeper, and Prism Launcher" "ON"
  "security" "Recon/security tools: nmap, hashcat, seclists, tcpdump" "ON"
  "devops" "Terraform, Ansible, PowerShell, WinRM, and linting" "ON"
  "remote" "VPN, FileZilla, Remmina, and Raspberry Pi Imager" "ON"
  "steam" "Steam, Gamescope, Proton-GE, and xone controller support" "ON"
  "virtualization" "Libvirt, virt-manager, SPICE, and full VM support" "ON"
  "kali" "Kali distrobox packages and bootstrap service" "ON"
  "networkExtras" "Tailscale, GlobalProtect, and Wireshark" "ON"
  "syncthing" "Syncthing service" "ON"
  "proxy" "Shadowsocks client and proxychains" "ON"
  "printing" "Printing and Avahi discovery" "ON"
  "bluetooth" "Bluetooth and Blueman" "ON"
  "phones" "iPhone/USB phone storage support" "ON"
  "flatpak" "Flatpak service" "ON"
  "power" "cpupower and suspend-then-hibernate policy" "ON"
  "ssh" "OpenSSH daemon with the firewall kept closed" "ON"
)

feature_selection=$(
  whiptail \
    --title "Optional Components" \
    --separate-output \
    --checklist "Uncheck components that this endpoint should not receive. The Hyprland desktop, base CLI, user setup, boot, audio, firewall, theming, and core maintenance stay enabled." \
    24 100 14 \
    "${feature_args[@]}" \
    3>&1 1>&2 2>&3
) || exit 1

selected_features=()
if [[ -n $feature_selection ]]; then
  while IFS= read -r feature; do
    [[ -n $feature ]] && selected_features+=("$feature")
  done <<< "$feature_selection"
fi

if ((${#selected_features[@]} == 0)); then
  features_env="__none__"
  features_summary="none"
else
  features_env="$(join_by "," "${selected_features[@]}")"
  features_summary="$(join_by ", " "${selected_features[@]}")"
fi

# Confirmation to continue
confirm_msg=$(printf "Proceed with install for host '%s' and username '%s'?\n\nOptional components:\n%s" "$host" "$username" "$features_summary")

if ! whiptail --yesno "$confirm_msg" 18 90 --title "Continue"; then
  echo "${info}Exiting."
  exit 0
fi

# Install
echo "${info}Starting system build."
echo "${info}This could take a while..."
sudo env NIXOS_CONFIG_USERNAME="$username" NIXOS_CONFIG_FEATURES="$features_env" nixos-rebuild switch --impure --flake ".#${host}"

echo "${ok}Done!"

# Confirmation to reboot
if whiptail --yesno "Reboot now?" 8 40 --title "Restart"; then
  sudo systemctl reboot
else
  echo "${info}Skipping reboot."
fi

exit 0
