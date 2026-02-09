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

# Pkgs
#while true; do
  
#done

# Confirmation to continue
if ! whiptail --yesno "Proceed with install for host '$host' and username '$username'?" 10 70 --title "Continue"; then
  echo "${info}Exiting."
  exit 0
fi

# Install
echo "${info}Starting system build."
echo "${info}This could take a while..."
sudo nixos-rebuild switch --flake ".#${host}"

echo "${ok}Done!"

# Confirmation to reboot
if whiptail --yesno "Reboot now?" 8 40 --title "Restart"; then
  sudo systemctl reboot
else
  echo "${info}Skipping reboot."
fi

exit 0
