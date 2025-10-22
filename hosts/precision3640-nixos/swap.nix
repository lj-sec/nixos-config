{ ... }:
{
  boot = {
    kernelParams = [
      "resume_offset=1612890"
    ];
    resumeDevice = "/dev/disk/by-uuid/9d503218-f3c5-4f51-4f51-b4e2-4fd114b97c85";
  };

  swapDevices = [
    {
      device = "/var/lib/swap/swapfile"; # perms 600; created with chattr +C on the dir
      size = 16 * 1024; # 16G in MB
    }
  ];
}
