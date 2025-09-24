{ inputs, ... }:
{
  imports = [
    # Systemd boot
    ./bootloader.nix
    # Bluetooth control
    ./bluetooth.nix
    # Home-manager, invokes the home module
    ./home.nix
    # Networking, hostname, Tailscale
    ./network.nix
    # Audio settings
    ./pipewire.nix
    # Any extra services necessary at core level
    ./services.nix
    # Nix settings, system packages
    ./system.nix
    # Wayland settings
    ./wayland.nix
    # Libvirtd, spice, virt-manager
    ./virtualization.nix
    # Steam/Proton settings
    ./steam.nix
    # Pam/Polkit
    ./security.nix
    # Greeter launches hyprlock as user
    ./greetd.nix
  ];
}
