{ ... }:
{
  powerManagement.enable = true;

  systemd.sleep.settings.Sleep = {
    HibernateDelaySec = "10m";
  };

  services.logind.settings.Login = {
    HandleLidSwitch = "suspend-then-hibernate";
    HandleLidSwitchExternalPower = "suspend-then-hibernate";
  };
}
