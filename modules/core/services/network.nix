{ pkgs, lib, host, ... }:
{
  networking = {
    hostName = host;
    networkmanager.enable = true;
  };

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
  };

  environment.systemPackages = with pkgs; [
    gpclient
    glib-networking
    gsettings-desktop-schemas
  ];

  programs.dconf.enable = true;
}
