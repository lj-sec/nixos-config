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
    wireshark
  ];

  programs.wireshark.enable = true;

  programs.dconf.enable = true;
}
