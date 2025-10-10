{ ... }:
{
  boot.kernelParams = [
    "resume_offset=9856316"
  ];

  boot.resumeDevice = "/dev/disk/by-uuid/acb5baf1-35a9-4cb1-887c-7a6942af3dea";

  powerManagement.enable = true;

  swapDevices = [
    {
      device = "/var/lib/swap/swapfile";  # perms 600; created with chattr +C on the dir
      size = 80 * 1024; # 80GB in MB
    }
  ];
  
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
