{ ... }: {
  networking.firewall = {
    enable = true;
    allowPing = true;
    # Example: tailscale/ssh already handled elsewhere, add custom ports here if needed
    # allowedTCPPorts = [ 22 ];
  };
}