{ pkgs, ... }:
{
  networking = {
    hostName = "t14g5-nixos";
    networkmanager.enable = true;
  };
  services.tailscale.enable = true;
}
