{ ... }:
{
  powerManagement.enable = true; 

  # After suspending, hibernate after 10 minutes
  systemd.sleep = {
    extraConfig = ''
      HibernateDelaySec=10m
    '';
  };
  
  services.logind = {
    settings.Login = {
      IdleAction = "suspend-then-hibernate";
      IdleActionSec = "30min";

      # Lid behavior
      HandleLidSwitch = "suspend-then-hibernate";
      HandleLidSwitchExternalPower = "suspend-then-hibernate";
    };
  };
}