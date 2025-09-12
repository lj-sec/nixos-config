{ inputs, ... }:
{
  imports = [ 
    ./config.nix
    ./hyprland.nix
    ./hyprlock.nix
    ./variables.nix
    ./polkit.nix
    inputs.hyprland.homeManagerModules.default
  ];
}