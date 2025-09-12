{ ... }:
{
  imports = [
    # Wayland Compositor
    ./hyprland
    # Custom taskbar
    ./waybar.nix
    # Notifications
    ./swaync
    # Terminal
    ./kitty.nix
    # Application Launcher
    ./rofi.nix
    # Git
    ./git.nix
    # Brave Browser
    ./brave.nix
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
    # VSCodium themes, config
    ./vscode
    # All other packages with no config
    ./packages.nix
  ];
}
