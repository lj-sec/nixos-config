{ ... }:
{
  boot.kernelParams = [
    "resume_offset=18883840"
  ];

  boot.resumeDevice = "/dev/disk/by-uuid/6e431e35-0712-4d4a-8dd4-7fd6263797b4";

  powerManagement.enable = true; 

  swapDevices = [
    {
      device = "/var/lib/swap/swapfile";  # perms 600; created with chattr +C on the dir
      size = 20 * 1024; # 20GB in MB
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