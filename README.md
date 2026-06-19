<div align="center">

<p align="center">
  <a href="https://github.com/lj-sec" target="_blank">
    <img src="./.github/assets/nix-snowflake.png"/>
  </a>
</p>

<p align="center">
  <img src="https://img.shields.io/github/stars/lj-sec/nixos-config?style=for-the-badge"/>
  <a href="https://nixos.org">
    <img src="https://img.shields.io/badge/NIXOS-5277C3.svg?style=for-the-badge&logo=NixOS&logoColor=white"/>
  </a>
</p>

<p align="center">
  <a href="https://github.com/lj-sec">
    <img src="https://img.shields.io/github/followers/lj-sec?label=Follow%20@lj-sec" alt="Follow @lj-sec"/>
  </a>
</p>

# LJ's NixOS Flake

</div>

This repository contains declarative NixOS host configurations managed with flakes and Home Manager.
The goal is a usable, user-friendly NixOS setup that stays out of the way for daily work.

---

## Screenshots

- **Desktop**  
  ![Desktop1](./.github/screenshots/screenshot1.png)
  ![Desktop2](./.github/screenshots/screenshot2.png)

- **Hyprlock**  
  ![Hyprlock](./.github/screenshots/screenshot3.png)

- **Wlogout**
  ![Wlogout](./.github/screenshots/screenshot4.png)

---

## Directory Structure

```
nixos-config/
├── flake.nix
├── flake.lock
├── hosts/
│   ├── desktop/
│   ├── laptop/
│   ├── server/
│   └── vm/
├── modules/
│   ├── core/
│   │   └── services/
│   └── home/
│       ├── distrobox/
│       │   ├── kali/
│       │   └── etc...
│       ├── hyprland/
│       ├── theme/
│       └── vscode/
└── wallpapers/
```
---

## Features

- **Hyprland** as the Wayland compositor, with 10 workspaces
- **Rofi** as the application launcher
- **Waybar** as the status bar with functional and clickable modules
- **SwayNC** as the notification daemon and center
- **Fish shell** with declarative aliases and customizations
- **Catppuccin** and shared palette integration for consistent theming across supported apps
- **Gaming support** via Steam and GE-Proton
- **Virtualization support** via libvirt, virt-manager, and SPICE
- **Distrobox** for containers
  - **Kali Linux** configuration is located at `./modules/home/distrobox/kali`, where apt packages can be declaratively defined

---

## Fish Aliases

<details>
  <summary>rebuild</summary>

  ### Usage:
  ```bash
  rebuild [ACTION] [FLAKE] [HOST]
  ```

  ### Output:
  ```bash
  sudo nixos-rebuild [ACTION] [FLAKE]#[HOST]
  ```

  ### Default:
  ```bash
  sudo nixos-rebuild switch .#$(hostname)
  ```
</details>

<details>
  <summary>passcp</summary>

  ### Usage:
  ```bash
  passcp [ACCOUNT]
  ```

  ### Output:
  ```bash
  pass show [ACCOUNT] | wl-copy
  ```
</details>

<details>
<summary>promisc</summary>

  ### Usage:
  ```bash
  promisc [INTERFACE]
  ```

  ### Output:
  ```bash
  # Toggle promisc:
  sudo ip link set [INTERFACE] promisc on
  # Or, if on:
  sudo ip link set [INTERFACE] promisc off
  ```
</details>

<details>
<summary>split_dir</summary>

  ### Usage:
  ```bash
    split_dir <SRC> <OUTDIR> <MULT><SIZE>"
  ```

  ### Output:
  Splits the SRC directory into OUTDIR into directories that are of <MULT><SIZE> or smaller where <MULT> is how many of <SIZE> bytes.

  ### Examples:
  ```bash
  split_dir ./data/ ./output/       # Default splits into equal chunks
  split_dir ./data/ ./output/ 50MB  # 50MB even dirs
  split_dir ./data/ ./output/ 1.5GB # 1.5GB even dirs
  ```

</details>

<details>
<summary>gpssl</summary>

  ### Alias:
  ```bash
  sudo gpclient --fix-openssl connect
  ```
</details>

<details>
  <summary>l</summary>

  ### Alias:
  ```bash
  ls -alh
  ```
</details>

<details>
<summary>ll</summary>

  ### Alias:
  ```bash
  ls -l
  ```
</details>

<details>
<summary>gs</summary>

  ### Alias:
  ```bash
  git status
  ```
</details>

---

## System Notes

The `desktop` host is being tested on an HP Omen-30l with i9-10850K with an NVIDIA RTX 3070.
The `laptop` host targets a Lenovo Thinkpad T14 Gen5 with a Ryzen 5 PRO 8540U with integrated 740m graphics.
Some host-specific quirks are documented in the relevant host module:
 - The laptop mic-mute button and LED need direct LED state handling from `./hosts/laptop/default.nix`.
 - Some tested Steam games on the laptop require the GE-Proton compatibility tool.

---


## Installation

> [!CAUTION]  
> The author is **not responsible** for any data loss, broken systems, or misconfigurations that may result from using this repository.
> Use at your own risk, and review configs before applying them to your machine.

> [!WARNING]  
> This configuration is tailored to specific host hardware, and sits on top of btrfs.
> You will need to adjust `hosts/<your-host>/hardware-configuration.nix` and other modules for your setup.
> You will also need to choose a swapfile size and verify hibernation offsets on the installed machine.

The current reinstall workflow is documented in [`docs/reinstall.md`](./docs/reinstall.md). Use it for:

- full-disk NixOS reinstall on a target machine
- installing an existing host onto filesystems already mounted at `/mnt`
- selecting a fixed flake host, networking hostname, and driver profile
- choosing plain root, LUKS passphrase unlock, or LUKS TPM2 PCR 7 unlock
- optionally enabling Lanzaboote/Secure Boot for the installed host
- understanding the Btrfs swapfile and hibernation offset

Quick full-disk reinstall entrypoint from a NixOS installer shell:

```bash
git clone https://github.com/lj-sec/nixos-config.git
cd nixos-config
sudo bash scripts/full-disk-install.sh --host laptop --username curse
```

The script prompts for `networking.hostName` and a driver profile, prints the
selected disk, and requires an exact `WIPE /dev/...` confirmation before
partitioning or formatting. It also prompts for encryption and Lanzaboote. TPM2
PCR 7 unlock keeps the original LUKS passphrase as a fallback and prints the
post-install `systemd-cryptenroll` command after installation.

### 0. Requirements

- NixOS 26.05 stable or the stable release tracked by `flake.nix`
- Home Manager module support
- UEFI system with Btrfs (recommended)
- Internet connection for flake inputs

If you’re starting from scratch:
 - Download the official ISO: [https://nixos.org/download](https://nixos.org/download)
 - Follow the official installation guide: [https://nixos.org/manual/nixos/stable/#sec-installation](https://nixos.org/manual/nixos/stable/#sec-installation)
 - Partition your drive with EFI + Btrfs, or your file system of choice
 - When finished, your system’s hardware configuration will live at `/etc/nixos/hardware-configuration.nix`

Once NixOS boots successfully, continue below to integrate this flake.

### 1. Choose host, hostname, driver profile, and swap

The fixed flake hosts are `desktop`, `laptop`, `server`, and `vm`. The flake
host name can differ from the installed system hostname; the installer writes
the chosen hostname to `hosts/<host>/local.nix`.

The installer also asks for a driver profile. Available profiles are `auto`,
`none`, `amd`, `intel`, `nvidia`, and `vm`.

Hosts use the NixOS `swapDevices.*.size` option so NixOS creates the swapfile.
On Btrfs, current NixOS uses `btrfs filesystem mkswapfile`, which satisfies the
no-COW/no-holes swapfile requirements.

For hibernation, record the Btrfs resume offset after the real swapfile exists:

```bash
sudo btrfs inspect-internal map-swapfile -r /var/lib/swap/swapfile
```

The full-disk installer does this automatically and writes the result into
`hosts/<host>/swap.nix`.

### 2. Install or rebuild

For a full-disk reinstall:

```bash
sudo bash scripts/full-disk-install.sh --host laptop --username curse
```

For filesystems that are already mounted at `/mnt`, use the mounted install path from `./installer.sh` or run:

```bash
sudo nixos-install --flake .#laptop
```

For an already-installed system, rebuild from the root of the repository:

```bash
sudo nixos-rebuild switch --flake .#desktop
```

---

## Shoutout

A lot of inspiration (and some configs) came from [Frost-Phoenix’s nixos-config](https://github.com/Frost-Phoenix/nixos-config/tree/main).

---

## Wallpapers

Wallpapers in the `./wallpapers/` directory were sourced from multiple sites across the internet, this is simply a small collection.
I do not claim ownership of any these images. All rights belong to their respective creators.

If you are the copyright holder of one of these wallpapers and would like it removed or credited differently, please contact me.

The default wallpapers directory that waypaper searches is `/home/${username}/Pictures/wallpapers` and can be changed in `./modules/home/waypaper.nix`.
