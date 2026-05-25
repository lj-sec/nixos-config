{ pkgs, lib, host, installFeatures ? {}, ... }:
let
  feature = name:
    if builtins.hasAttr name installFeatures then installFeatures.${name} else true;
in
lib.mkMerge [
  {
    networking = {
      hostName = host;
      networkmanager.enable = true;
    };

    programs.dconf.enable = true;
  }

  (lib.mkIf (feature "networkExtras") {
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
  })
]
