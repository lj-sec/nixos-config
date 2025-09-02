{ inputs, ... }:
{
  imports = [ 
    ./config.nix
    ./hyprland.nix
    ./hyprlock.nix
    ./variables.nix
    inputs.hyprland.homeManagerModules.default
  ];
}
