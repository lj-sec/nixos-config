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

## Installing an existing host

Boot a NixOS installer, clone this repository, and run:

```sh
./installer.sh
```

Choose the mounted-install path for an already partitioned target, or the
full-disk install path when the selected disk may be completely erased. The
full-disk path requires typing an exact `WIPE /dev/...` confirmation before it
formats anything.

Do not assume a disk name. Confirm the target with `lsblk` from the installer
environment before selecting it.

## Generating a new host

Run:

```sh
./installer.sh
```

Choose the new-host generator. It creates `hosts/<name>/` with host metadata,
hardware placeholders, optional fingerprint support, swapfile settings, and the
selected profile imports. Review the generated files before installing.

## Swapfile generation

Hosts use a per-host `swap.nix`. For Btrfs filesystems, generate or update the
swapfile from the installer after the target filesystem is mounted at `/mnt`.
The helper creates a NixOS-managed swapfile path under `/swap/` and writes the
host setting so the installed system owns activation.

Existing hosts can set `swap.size` in `hosts/<name>/meta.nix`; the installer
uses that value when regenerating swap configuration.

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
