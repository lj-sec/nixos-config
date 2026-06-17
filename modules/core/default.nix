{ lib, installFeatures ? {}, ... }:
let
  feature = name:
    if builtins.hasAttr name installFeatures then installFeatures.${name} else true;
in
{
  imports = [
    # Systemd boot
    ./bootloader.nix
    # Home-manager, invokes the home module
    ./home.nix
    # Nix settings, system packages
    ./system.nix
    # Installer-selected hardware driver profile
    ./hardware-profile.nix
    # Wayland settings
    ./wayland.nix
  ]
  ++ lib.optionals ((feature "virtualization") || (feature "kali")) [
    # Libvirtd, spice, virt-manager
    ./virtualization.nix
  ]
  ++ lib.optionals (feature "steam") [
    # Steam/Proton settings
    ./steam.nix
  ]
  ++ [
    # All other services
    ./services
  ];
}
