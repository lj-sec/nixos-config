{ ... }: {
  networking.firewall = {
    enable = true;
    allowPing = true;
    # tailscale/ssh already handled elsewhere, add custom ports here if needed
    # allowedTCPPorts = [ 22 ];
  };
}