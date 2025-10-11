{ pkgs, config, ... }:
{
  imports = [
    ./swap.nix
    ./hardware-configuration.nix
    ./../../modules/core
  ];
}
