#!/usr/bin/env bash
set -eou pipefail

PKGFILE="$HOME/.config/distrobox/kali/apt-packages.txt"

sudo apt update

sudo DEBIAN_FRONTEND=noninteractive apt-get install -y $(grep -vE '^\s*#|^\s*$' "$PKGFILE")