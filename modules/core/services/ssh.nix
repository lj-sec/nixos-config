{ ... }:
{
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      X11Forwarding = false;
      AllowAgentForwarding = "no";
      ClientAliveInterval = 60;
      ClientAliveCountMax = 2;
    };
    openFirewall = false; # keep ssh closed unless you explicitly open it
  };
}