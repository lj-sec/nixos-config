{ ... }:
{
  imports = [
    # Printing + Avahi discovery
    ./printing.nix
    # Time sync and zone
    ./time.nix
    # Firewall enabling and ports
    ./firewall.nix
    # SSH configuration
    ./ssh.nix
    # Garbage collection, btrfs
    ./maintenance.nix
    # Blueman configuration
    ./bluetooth.nix
    # Greetd -> hyprland
    ./greetd.nix
    # Networking + VPNs
    ./network.nix
    # Audio configuration
    ./pipewire.nix
    # PAM/Polkit + fprintd
    ./security.nix
    # Power configuration and management
    ./power.nix
    # Sleep daemon
    ./sleep.nix
    # Sync certain folders
    ./syncthing.nix
    # Yikes
    # ./jank.nix
  ];
}