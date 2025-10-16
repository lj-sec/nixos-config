{ inputs, ... }:
{
  imports = [
    # Systemd boot
    ./bootloader.nix
    # Home-manager, invokes the home module
    ./home.nix
    # Nix settings, system packages
    ./system.nix
    # Wayland settings
    ./wayland.nix
    # Libvirtd, spice, virt-manager
    ./virtualization.nix
    # Steam/Proton settings
    ./steam.nix
    # All other services
    ./services
  ];
}