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
    <img src="https://img.shields.io/github/followers/lj-sec?label=Follow%20@lj-sec&style=social" alt="Follow @lj-sec"/>
  </a>
</p>

# LJ's NixOS Flake

</div>

My fully declarative NixOS configuration, managed with flakes and home-manager.
It’s built for a clean, reliable, and reproducible single-user environment optimized for productivity and schoolwork with support for Steam/Proton, virtualization, and lightweight security/pentesting tooling.
The configuration also enables `allowUnfree = true;` to support proprietary applications like Brave, Spotify, and Steam.
Packages and configurations evolve as my workflow changes.

---

## Screenshots
A few visuals of the desktop and utilities included in this setup:

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
│   ├── t14g5-nixos/
│   └── omen30l-nixos/
├── modules/
│   ├── core/
│   │   └── services/
│   └── home/
│       ├── hyprland/
│       ├── theme/
│       └── vscode/
└── wallpapers/
```
---

## Features

- **Hyprland** as the Wayland compositor, with 10 workspaces
- **Hyprlock** as the one and only screen locking utility and sign-in screen for a single user
- **Rofi** as the fast, lightweight application launcher
- **Waybar** as the status bar with functional and clickable modules
- **SwayNC** as the notification daemon and center
- **Fish shell** with declarative aliases and customizations
- **Nix-Colors** integration for consistent theming across supported apps
- **GTK theming** for cursor, fonts, and color schemes
- **Security tools** with packages for hardening, recon, and penetration testing
- **Gaming support** via Steam and GE-Proton
- **Virtualization support** including libvirt, virt-manager, and SPICE
- Includes a wide selection of daily-use applications for a stable, everyday workflow.

---

## Fish Aliases

<details>
<summary>rebuild</summary>

### Usage:
```bash
rebuild [ACTION] [FLAKE] [HOST]
```

### Output:
```
sudo nixos-rebuild [ACTION] [FLAKE]#[HOST]
```

### Default:
```
sudo nixos-rebuild switch .#$(hostname)
```

</details>

---

## System Notes

This setup was primarily built and tested on a Lenovo ThinkPad T14 Gen5 (AMD, 21MC).  
Some quirks have been noted:
 - This keyboard's micmute button and LED have been impossible to configure, as it is not throwing XF86AudioMicMute when pressed as it should. In this repo I have created a script and a service that hooks into wireplumber and pipewire to ensure the accuracy of the LED via writing directly to `/sys/class/leds/platform::micmute/brightness` and the waybar custom-mic module. For now, I have also bound SUPER + M to toggle the microphone.
 - The Steam games that have been tested on the ThinkPad (i.e. Noita, Balatro) have only launched when forced to use the GE-Proton Compatibility tool. When using GE-Proton, no issues.
 - The custom waybar-lyric module will use high CPU when Spotify has not been launched at least once in the environment. Workaround is Spotify is launched in workspace 5 on boot. This module works cleanly unless the Spotify DJ is talking, to which it crashes.

The other system currently being tested is an HP Omen 30L (i9-10850K, RTX 3070), which successfully built on the second attempt after configuring the swapfile correctly, despite the hardware differences. Updates to come.

---


## Installation

> [!CAUTION]  
> I am **not responsible** for any data loss, broken systems, or misconfigurations that may result from using this repository. This is still in an early stage.
> Use at your own risk, and review configs before applying them to your machine.

> [!WARNING]  
> This configuration is tailored to my hardware, and sits on top of btrfs.  
> You will need to adjust `hosts/<your-host>/hardware-configuration.nix` and other modules for your setup.
> You will also need to create your own swapfile or adjust the path(s) in `modules/core/sleep.nix`

### 0. Requirements

- NixOS 25.05 or newer
- Home Manager module support
- UEFI system with Btrfs (recommended)
- Internet connection for flake inputs

If you’re starting from scratch:
 - Download the official ISO: → [https://nixos.org/download](https://nixos.org/download)
 - Follow the official installation guide: → [https://nixos.org/manual/nixos/stable/#sec-installation](https://nixos.org/manual/nixos/stable/#sec-installation)
 - Partition your drive with EFI + Btrfs, or your file system of choice
 - When finished, your system’s hardware configuration will live at `/etc/nixos/hardware-configuration.nix`

Once NixOS boots successfully, continue below to integrate this flake.

### 1. Create a swap file for hibernation:

```bash
sudo mkdir -p /var/lib/swap
sudo chattr +C /var/lib/swap                # Disable COW on btrfs
sudo fallocate -l <size-of-RAM>G /var/lib/swap/swapfile
sudo chmod 600 /var/lib/swap/swapfile
sudo mkswap /var/lib/swap/swapfile
```

Then record the device UUID and offset (you’ll need these for your swap.nix):
```bash
# Find UUID of the partition containing your swapfile
df --output=source /var/lib/swap/swapfile | tail -1

# On btrfs, find the swapfile offset:
sudo btrfs inspect-internal map-swapfile -r /var/lib/swap/swapfile
```

### 2. Set up host configuration:

You have two choices:

<details>
<summary>Option A - Modifying an existing host</summary>
<br>
Clone this repository and enter it:

```bash
git clone https://github.com/lj-sec/nixos-config.git
cd nixos-config
```

Replace the contents of one of the present host's hardware-configuration.nix with your own:
```bash
sudo cp /etc/nixos/hardware-configuration.nix hosts/<your-host>/hardware-configuration.nix
```

Open `hosts/<your-host>/swap.nix` in your editor of choice and update:
 - `resume_offset=` → your offset from earlier
 - `resumeDevice=` → your swap partition’s UUID path
 - `size=` → the size of your swapfile in GiB

Ensure that in flake.nix the specialArgs `hasFingerprint` aligns with your preference on fingerprint authentication.

And you're finished with this step!

</details>

<details>
<summary>Option B - Creating your own host</summary>
<br>

```bash
git clone https://github.com/lj-sec/nixos-config.git
cd nixos-config/hosts
mkdir <your-host>
sudo cp /etc/nixos/hardware-configuration.nix <your-host>
touch <your-host>/default.nix
touch <your-host>/swap.nix
```
Modify default.nix and swap.nix with your editor of choice, mimicking the setup that is present in the other hosts present.
Ensure that `<your-host>/default.nix` imports `./../../modules/core`, `./hardware-configuration.nix`, and `./swap.nix` at a minimum, as that ensures the rest of the flake is strapped in.

Once that is completed, navigate back to the root of the repository (pwd should be nixos-config). Find the flake.nix file and modify it with your editor of choice to include your new host underneath the present hosts as such:
```nix
<your-host> = lib.nixosSystem {
  inherit system;
  modules = [
    { nixpkgs.overlays = [ self.overlays.waybar-lyric-fix ]; }
    ./hosts/<your-host> 
  ];
  specialArgs = {
    hasFingerprint = <true/false>;
    host = "<your-host>";
    inherit self inputs username;
  };
};
```

And you're finished with this setup!

---

</details>

### 3. Apply the configuration

Finally, from the root of the repository:
```
sudo nixos-rebuild switch --flake .#<your-host>
```

---

## Shoutout

- [Frost-Phoenix](https://github.com/Frost-Phoenix/) for their [nixos-config](https://github.com/Frost-Phoenix/nixos-config/tree/main)
- [Misterio77](https://github.com/Misterio77) for [nix-colors](https://github.com/Misterio77/nix-colors) and [nix-starter-configs](https://github.com/Misterio77/nix-starter-configs)
- [Melkor333](https://github.com/Melkor333) for [nixos-boot](https://github.com/Melkor333/nixos-boot) to which I forked at [lj-sec/nixos-boot](https://github.com/lj-sec/nixos-boot)
- [tony](https://www.youtube.com/@tony-btw) and [Vimjoyer](https://www.youtube.com/@vimjoyer) on YouTube for NixOS tutorial content

---

## Background Credit

The wallpapers in the `./wallpapers/` directory were sourced from [WallpaperAccess](https://wallpaperaccess.com/).  
I do not claim ownership of these images. All rights belong to their respective creators.

If you are the copyright holder of one of these wallpapers and would like it removed or credited differently, please [contact me](https://lj-sec.github.io).s