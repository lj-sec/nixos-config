{ ... }:
{
  powerManagement.enable = true;

  systemd.sleep.settings.Sleep = {
    HibernateDelaySec = "10m";
  };

  services.logind.settings.Login = {
    IdleAction = "suspend-then-hibernate";
    IdleActionSec = "30min";

    HandleLidSwitch = "suspend-then-hibernate";
    HandleLidSwitchExternalPower = "suspend-then-hibernate";
  };
}