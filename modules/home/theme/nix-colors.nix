{ inputs, ... }:
{
  imports = [
    inputs.nix-colors.homeManagerModule
  ];
  colorScheme = inputs.nix-colors.colorSchemes.ayu-dark;
}
