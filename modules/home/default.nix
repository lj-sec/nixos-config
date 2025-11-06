{ ... }:
{
  imports = [
    # Audio display
    # ./cava.nix
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
    # Password manager
    ./pass.nix
    # Logout manager
    ./wlogout.nix
    # All other packages with no config
    ./packages.nix
  ];
}
