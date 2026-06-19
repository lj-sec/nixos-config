{ ... }:
{
  boot = {
    kernelParams = [
      "resume_offset=533760"
    ];
    resumeDevice = "/dev/disk/by-uuid/5068c0e8-469c-4e68-b166-a2aee64bb2a9";
  };

  swapDevices = [
    {
      device = "/var/lib/swap/swapfile"; # Btrfs-safe swapfile managed by NixOS when size is set
      size = 16 * 1024; # 16G in MB
    }
  ];
}
