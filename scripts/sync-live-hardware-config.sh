#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo="$(cd -- "$script_dir/.." && pwd)"

mode="write"
host=""

usage() {
  cat <<'USAGE'
Usage: scripts/sync-live-hardware-config.sh [--check] [HOST]

Synchronize hosts/<host>/hardware-configuration.nix filesystem UUIDs with the
currently mounted system. When HOST is omitted, the script matches the current
hostname against hosts/*/local.nix networkingHostName.
USAGE
}

die() {
  printf 'ERROR %s\n' "$*" >&2
  exit 1
}

require_cmd() {
  local missing=()
  local cmd
  for cmd in "$@"; do
    command -v "$cmd" >/dev/null 2>&1 || missing+=("$cmd")
  done
  ((${#missing[@]} == 0)) || die "Missing required command(s): ${missing[*]}"
}

host_from_local_config() {
  local local_file="$1"
  awk -F'"' '/networkingHostName[[:space:]]*=/ { print $2; exit }' "$local_file"
}

detect_host() {
  local current_hostname
  current_hostname="$(hostname)"

  if [[ -d "$repo/hosts/$current_hostname" ]]; then
    printf '%s\n' "$current_hostname"
    return
  fi

  local local_file configured_hostname
  for local_file in "$repo"/hosts/*/local.nix; do
    [[ -f "$local_file" ]] || continue
    configured_hostname="$(host_from_local_config "$local_file")"
    if [[ "$configured_hostname" == "$current_hostname" ]]; then
      basename "$(dirname "$local_file")"
      return
    fi
  done

  die "Could not infer flake host for hostname '$current_hostname'. Pass HOST explicitly."
}

mount_uuid() {
  local target="$1"
  local source uuid

  uuid="$(findmnt -no UUID --target "$target" 2>/dev/null | awk 'NF { print; exit }')"
  if [[ -n "$uuid" ]]; then
    printf '%s\n' "$uuid"
    return
  fi

  source="$(findmnt -no SOURCE --target "$target" 2>/dev/null || true)"
  [[ -n "$source" ]] || return 1
  source="${source%%[*}"
  uuid="$(lsblk -no UUID "$source" | awk 'NF { print; exit }')"
  [[ -n "$uuid" ]] || die "Could not resolve UUID for $target from $source"
  printf '%s\n' "$uuid"
}

sed_regex_escape() {
  printf '%s' "$1" | sed 's/[.[\*^$()+?{}|\\]/\\&/g; s#/#\\/#g'
}

sync_mount() {
  local file="$1"
  local mountpoint="$2"
  local uuid="$3"
  local escaped_mountpoint

  escaped_mountpoint="$(sed_regex_escape "$mountpoint")"
  sed -i -E \
    "/^[[:space:]]*fileSystems\\.\"${escaped_mountpoint}\"[[:space:]]*=[[:space:]]*\\{/,/^[[:space:]]*\\};/ s#(device[[:space:]]*=[[:space:]]*\")/dev/disk/by-uuid/[^\"]*(\";)#\\1/dev/disk/by-uuid/${uuid}\\2#" \
    "$file"
}

while (($# > 0)); do
  case "$1" in
    --check)
      mode="check"
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    -*)
      die "Unknown option: $1"
      ;;
    *)
      [[ -z "$host" ]] || die "Only one HOST may be provided."
      host="$1"
      ;;
  esac
  shift
done

require_cmd awk basename dirname findmnt hostname lsblk mktemp sed

host="${host:-$(detect_host)}"
hardware_config="$repo/hosts/$host/hardware-configuration.nix"
[[ -f "$hardware_config" ]] || die "Missing hardware config: $hardware_config"

tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT
cp "$hardware_config" "$tmp"

for mountpoint in / /home /nix /var/log /.snapshots /boot; do
  uuid="$(mount_uuid "$mountpoint" || true)"
  [[ -n "${uuid:-}" ]] || continue
  sync_mount "$tmp" "$mountpoint" "$uuid"
done

if cmp -s "$hardware_config" "$tmp"; then
  printf 'Hardware config already matches live mounts for host %s.\n' "$host"
  exit 0
fi

if [[ "$mode" == "check" ]]; then
  printf 'Hardware config differs from live mounts for host %s:\n' "$host" >&2
  diff -u "$hardware_config" "$tmp" >&2 || true
  exit 1
fi

cp "$tmp" "$hardware_config"
printf 'Updated %s to match live filesystem UUIDs.\n' "$hardware_config"
