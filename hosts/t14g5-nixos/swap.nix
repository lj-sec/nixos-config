{ ... }:
{
  boot = {
    kernelParams = [
      "resume_offset=18883840"
    ];
    resumeDevice = "/dev/disk/by-uuid/6e431e35-0712-4d4a-8dd4-7fd6263797b4";
  };

  swapDevices = [
    {
      device = "/var/lib/swap/swapfile"; # perms 600; created with chattr +C on the dir
      size = 20 * 1024; # 20G in MB
    }
  ];
}