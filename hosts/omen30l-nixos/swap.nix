{ ... }:
{
  boot = {
    kernelParams = [
      "resume_offset=9856316"
    ];
    resumeDevice = "/dev/disk/by-uuid/acb5baf1-35a9-4cb1-887c-7a6942af3dea";
  };

  swapDevices = [
    {
      device = "/var/lib/swap/swapfile"; # perms 600; created with chattr +C on the dir
      size = 80 * 1024; # 80G in MB
    }
  ];
}