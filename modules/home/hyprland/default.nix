{ inputs, ... }:
{
  imports = [
    # General keybinds, exec-once, and window rules
    ./config.nix
    # General packages
    ./hyprland.nix
    # Screen locker and greeter
    ./hyprlock.nix
    # Executes hyprshade and hyprlock when idling
    ./hypridle.nix
    # Polkit
    ./polkit.nix
    # Screen shader configurations
    ./hyprshade.nix
    # Screen brightness reduction at sunset
    ./wlsunset.nix
    # Hyprland module
    inputs.hyprland.homeManagerModules.default
  ];
}