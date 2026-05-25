{ lib, installFeatures ? {}, ... }:
let
  feature = name:
    if builtins.hasAttr name installFeatures then installFeatures.${name} else true;
in
{
  imports = [
    # Audio display
    ./cava.nix
    # Wayland Compositor
    ./hyprland
    # Custom taskbar
    ./waybar.nix
    # Notifications
    ./swaync.nix
    # Terminal
    ./kitty.nix
    # File explorer
    ./nemo.nix
    # Application Launcher
    ./rofi.nix
    # Git
    ./git.nix
    # System Monitor
    ./btop.nix
    # Wallpaper
    ./waypaper.nix
    # Shell
    ./fish.nix
    # System Fetcher
    ./fastfetch.nix
    # GTK, cursor, fonts, nix-colors
    ./theme
    # Logout manager
    ./wlogout.nix
    # XDG-Mime
    ./xdg.nix
    # All other packages with no config
    ./packages.nix
  ]
  ++ lib.optionals (feature "kali") [
    # Containers
    ./distrobox
  ]
  ++ lib.optionals (feature "brave") [
    # Brave Browser
    ./brave.nix
  ]
  ++ lib.optionals (feature "vscode") [
    # VSCodium themes, config
    ./vscode
  ]
  ++ lib.optionals (feature "pass") [
    # Password manager
    ./pass.nix
  ]
  ++ lib.optionals (feature "communication") [
    # Discord client
    ./vesktop.nix
  ]
  ++ lib.optionals (feature "mail") [
    # Mail client
    ./thunderbird.nix
  ];
}
