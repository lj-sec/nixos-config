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

echo "${ok}Username set to ${green}${username}${reset}"
exit 0