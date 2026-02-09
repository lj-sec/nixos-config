{ config, pkgs, ... }:

{
  # IP forwarding for NAT
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  # Laptop ethernet side (LAN)
  networking.interfaces.enp1s0f0.ipv4.addresses = [{
    address = "192.168.50.1";
    prefixLength = 24;
  }];

  # NAT out through Wi-Fi
  networking.nat = {
    enable = true;
    externalInterface = "wlp2s0";
    internalInterfaces = [ "enp1s0f0" ];
  };

  # DHCP via dnsmasq
  services.dnsmasq = {
    enable = true;

    # Only listen/bind on the ethernet side so it doesn't fight your real router
    settings = {
      interface = "enp1s0f0";
      bind-interfaces = true;

      # DHCP range for the gaming PC
      dhcp-range = "192.168.50.100,192.168.50.200,255.255.255.0,12h";

      # Give the PC the laptop as gateway
      dhcp-option = [
        "option:router,192.168.50.1"
        "option:dns-server,1.1.1.1,8.8.8.8"
      ];
    };
  };

  # Firewall: trust LAN side
  networking.firewall = {
    enable = true;
    trustedInterfaces = [ "enp1s0f0" ];
  };
}
