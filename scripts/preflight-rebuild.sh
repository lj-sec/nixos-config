#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo="$(cd -- "$script_dir/.." && pwd)"

action="${1:-switch}"
host="${2:-}"

usage() {
  cat <<'USAGE'
Usage: scripts/preflight-rebuild.sh [ACTION] [HOST]

Run live-system safety checks before nixos-rebuild mutates boot state.
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

install_security_block() {
  local local_file="$1"
  awk '
    /^[[:space:]]*installSecurity[[:space:]]*=[[:space:]]*\{/ { in_block = 1 }
    in_block { print }
    in_block && /^[[:space:]]*\};/ { exit }
  ' "$local_file"
}

security_value() {
  local block="$1"
  local key="$2"

  printf '%s\n' "$block" | awk -v key="$key" '
    $1 == key && $2 == "=" {
      value = $3
      gsub(/;$/, "", value)
      gsub(/^"|"$/, "", value)
      print value
      exit
    }
  '
}

secure_boot_enabled() {
  local status efivar value

  if command -v bootctl >/dev/null 2>&1; then
    status="$(
      bootctl status 2>/dev/null \
        | awk -F: 'tolower($1) ~ /secure boot/ {
            value = tolower($2)
            gsub(/^[[:space:]]+|[[:space:]]+$/, "", value)
            print value
            exit
          }'
    )"
    [[ "$status" == enabled* ]] && return 0
    [[ "$status" == disabled* ]] && return 1
  fi

  for efivar in /sys/firmware/efi/efivars/SecureBoot-*; do
    [[ -e "$efivar" ]] || return 1
    value="$(od -An -j4 -N1 -tu1 "$efivar" 2>/dev/null | awk '{ print $1; exit }')"
    [[ "$value" == "1" ]]
    return
  done

  return 1
}

root_source() {
  local source
  source="$(findmnt -no SOURCE --target / 2>/dev/null || true)"
  source="${source%%[*}"
  printf '%s\n' "$source"
}

root_is_luks_mapper() {
  local source="$1"
  local type

  [[ -n "$source" ]] || return 1
  type="$(lsblk -no TYPE "$source" 2>/dev/null | awk 'NF { print; exit }')"
  [[ "$type" == "crypt" ]]
}

luks_parent_uuid() {
  local source="$1"
  local parent

  parent="$(lsblk -no PKNAME "$source" 2>/dev/null | awk 'NF { print; exit }')"
  [[ -n "$parent" ]] || return 1
  lsblk -no UUID "/dev/$parent" 2>/dev/null | awk 'NF { print; exit }'
}

case "$action" in
  -h|--help)
    usage
    exit 0
    ;;
esac

case "$action" in
  switch|boot|test)
    ;;
  *)
    printf 'Skipping live rebuild preflight for action %s.\n' "$action"
    exit 0
    ;;
esac

if [[ "${REBUILD_SKIP_PREFLIGHT:-}" == "1" ]]; then
  printf 'Skipping live rebuild preflight because REBUILD_SKIP_PREFLIGHT=1.\n'
  exit 0
fi

require_cmd awk basename dirname findmnt hostname lsblk od

current_host="$(detect_host)"
host="${host:-$current_host}"

if [[ "$host" != "$current_host" ]]; then
  if [[ "${REBUILD_ALLOW_FOREIGN_HOST:-}" == "1" ]]; then
    printf "Skipping live rebuild preflight for host '%s' while booted as '%s'.\n" "$host" "$current_host"
    exit 0
  fi
  die "Refusing '$action' for host '$host' while booted as '$current_host'. Set REBUILD_ALLOW_FOREIGN_HOST=1 only if this is intentional."
fi

local_file="$repo/hosts/$host/local.nix"
[[ -f "$local_file" ]] || die "Missing local host config: $local_file"

security_block="$(install_security_block "$local_file")"
configured_encryption="$(security_value "$security_block" encryption)"
configured_secure_boot="$(security_value "$security_block" secureBoot)"
configured_luks_uuid="$(security_value "$security_block" luksDeviceUuid)"

configured_encryption="${configured_encryption:-none}"
configured_secure_boot="${configured_secure_boot:-false}"

if secure_boot_enabled && [[ "$configured_secure_boot" != "true" ]]; then
  die "Firmware Secure Boot is enabled, but $local_file does not set installSecurity.secureBoot = true. Rebuilding would install unsigned boot entries."
fi

if [[ "$configured_secure_boot" == "true" && ! -f /var/lib/sbctl/keys/db/db.key ]]; then
  die "installSecurity.secureBoot is true, but /var/lib/sbctl keys are missing. Lanzaboote cannot sign the next generation."
fi

source="$(root_source)"
if root_is_luks_mapper "$source"; then
  case "$configured_encryption" in
    luks-passphrase|luks-tpm2)
      ;;
    *)
      die "Root is mounted from LUKS mapper $source, but $local_file does not declare LUKS in installSecurity.encryption."
      ;;
  esac

  live_luks_uuid="$(luks_parent_uuid "$source" || true)"
  if [[ -n "$live_luks_uuid" && -z "$configured_luks_uuid" ]]; then
    die "Root LUKS UUID is $live_luks_uuid, but $local_file does not set installSecurity.luksDeviceUuid."
  fi
  if [[ -n "$live_luks_uuid" && -n "$configured_luks_uuid" && "$configured_luks_uuid" != "$live_luks_uuid" ]]; then
    die "Root LUKS UUID is $live_luks_uuid, but $local_file sets installSecurity.luksDeviceUuid = $configured_luks_uuid."
  fi
fi

if [[ -x "$script_dir/sync-live-hardware-config.sh" ]]; then
  "$script_dir/sync-live-hardware-config.sh" --check "$host"
fi

printf 'Rebuild preflight checks passed for host %s.\n' "$host"
