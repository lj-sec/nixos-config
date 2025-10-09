{ pkgs, host, ... }:
{
  networking = {
    hostName = "${host}";
    networkmanager.enable = true;
  };
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
    # openFirewall = true; # only if you actually want inbound services via TS
  };
}
