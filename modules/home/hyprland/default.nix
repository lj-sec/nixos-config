{ inputs, ... }:
{
  imports = [ 
    ./config.nix
    ./hyprland.nix
    ./hyprlock.nix
    ./hypridle.nix
    ./variables.nix
    ./polkit.nix
    inputs.hyprland.homeManagerModules.default
  ];
}