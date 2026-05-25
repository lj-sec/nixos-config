{ lib, installFeatures ? {}, ... }:
let
  feature = name:
    if builtins.hasAttr name installFeatures then installFeatures.${name} else true;
in
{
  imports = [
    # Time sync and zone
    ./time.nix
    # Firewall enabling and ports
    ./firewall.nix
    # Garbage collection, btrfs
    ./maintenance.nix
    # Greetd -> hyprland
    ./greetd.nix
    # Networking + VPNs
    ./network.nix
    # Audio configuration
    ./pipewire.nix
    # PAM/Polkit + fprintd
    ./security.nix
  ]
  ++ lib.optionals (feature "phones") [
    # Reading phone storage
    ./phones.nix
  ]
  ++ lib.optionals (feature "printing") [
    # Printing + Avahi discovery
    ./printing.nix
  ]
  ++ lib.optionals (feature "ssh") [
    # SSH configuration
    ./ssh.nix
  ]
  ++ lib.optionals (feature "flatpak") [
    # Flatpaks
    ./flatpak.nix
  ]
  ++ lib.optionals (feature "bluetooth") [
    # Blueman configuration
    ./bluetooth.nix
  ]
  ++ lib.optionals (feature "power") [
    # Power configuration and management
    ./power.nix
    # Sleep daemon
    ./sleep.nix
  ]
  ++ lib.optionals (feature "syncthing") [
    # Sync certain folders
    ./syncthing.nix
  ]
  ++ lib.optionals (feature "proxy") [
    # Shadowsocks proxy service
    ./shadowsocks.nix
  ];
}
