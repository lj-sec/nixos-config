# Reinstall and Stable Release Guide

This repository tracks stable NixOS releases. The current release branch is
`nixos-26.05`.

## Updating to a future stable release

1. Change the primary `nixpkgs` input in `flake.nix` to the new stable branch,
   for example `github:NixOS/nixpkgs/nixos-26.11`.
2. Change Home Manager to the matching release branch, for example
   `github:nix-community/home-manager/release-26.11`.
3. Keep inputs that integrate with the system package set following `nixpkgs`
   unless their upstream documentation requires otherwise.
4. Run `nix flake update`, then run `nix flake check` and build each host
   toplevel before installing.

There are no unstable package inputs configured at this time. If a future
package requires unstable, isolate it behind a clearly named input or module and
document why it cannot use stable.

## Installing a fixed host

Boot a NixOS installer, clone this repository, and run:

```sh
./installer.sh
```

Choose the mounted-install path for an already partitioned target, or the
full-disk install path when the selected disk may be completely erased. The
full-disk path requires typing an exact `WIPE /dev/...` confirmation before it
formats anything.

The fixed flake hosts are `desktop`, `laptop`, `server`, and `vm`. The installer
asks for a separate networking hostname, so the flake host can stay fixed while
`networking.hostName` becomes whatever the installed machine should advertise on
the network. The selected hostname, username, driver profile, and optional
feature set are written to `hosts/<host>/local.nix` before install or rebuild,
so flake evaluation remains pure.

The installer also asks for a driver profile. Available profiles are `auto`,
`none`, `amd`, `intel`, `nvidia`, and `vm`.

The full-disk installer also asks for disk security choices:

- `none`: plain Btrfs root.
- `luks-passphrase`: LUKS root unlocked with a passphrase at boot.
- `luks-tpm2`: LUKS root configured for TPM2 PCR 7 unlock with the original
  passphrase kept as the fallback.

Lanzaboote/Secure Boot is optional per install. TPM2 PCR 7 mode requires
Lanzaboote in this installer because PCR 7 represents Secure Boot policy. The
installer generates Secure Boot signing keys in `/var/lib/sbctl` when possible,
but firmware key enrollment still happens after the first boot.

Do not assume a disk name. Confirm the target with `lsblk` from the installer
environment before selecting it.

## Secure Boot and TPM2 finalization

When Lanzaboote is selected, the installer prints the remaining steps at the
end of installation. The usual sequence is:

```sh
sudo sbctl status
sudo sbctl enroll-keys --microsoft
sudo sbctl verify
bootctl status
```

Before the first boot, make sure firmware Secure Boot is disabled or in setup
mode so the machine does not enforce old/vendor-only keys against the newly
signed Lanzaboote entries. Enter firmware Secure Boot setup mode before
enrolling keys, and do not clear the dbx database. After enrolling keys, reboot
and confirm `bootctl status` shows Secure Boot enabled in user mode.

For `luks-tpm2`, complete Secure Boot enrollment first, then bind the installed
LUKS container to TPM2 PCR 7:

```sh
sudo systemd-cryptenroll --wipe-slot=tpm2 --tpm2-device=auto --tpm2-pcrs=7 /dev/disk/by-uuid/<luks-uuid>
```

The installer prints the concrete LUKS UUID. Keep the original LUKS passphrase;
it remains the fallback unlock method if TPM unlock is unavailable.

## Swapfile generation

Hosts use a per-host `swap.nix`. For Btrfs filesystems, generate or update the
swapfile from the installer after the target filesystem is mounted at `/mnt`.
The full-disk helper creates `/var/lib/swap/swapfile` with
`btrfs filesystem mkswapfile`, records the fresh `resume_offset`, and writes the
host setting so the installed system owns activation.

Host metadata records the intended swap size. Pass a different size to the
full-disk installer with `--swap-gib`, or review `hosts/<name>/swap.nix` after
generation.

## Validation

Before installing, run the checks that apply in the current environment:

```sh
nix flake update
nix flake check
nix build .#nixosConfigurations.<host>.config.system.build.toplevel
nix fmt -- --check
shellcheck -x installer.sh scripts/*.sh
```

If a formatter is not configured, use the repository's existing formatting
style and rely on the Nix evaluation and build checks.
