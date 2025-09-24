{ inputs, ... }:
{
  imports = [ 
    ./config.nix
    ./hyprland.nix
    ./hyprlock.nix
    ./hypridle.nix
    ./variables.nix
    ./polkit.nix
    ./hyprshade.nix
    inputs.hyprland.homeManagerModules.default
  ];
}