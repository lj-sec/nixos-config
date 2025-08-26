{ pkgs, ... }:
{
  networking = {
    hostName = "t14g5-nixos";
    networkmanager.enable = true;
  };
}
