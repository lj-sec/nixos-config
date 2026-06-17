{ ... }:
{
  swapDevices = [
    {
      device = "/var/lib/swap/swapfile";
      size = 8 * 1024;
    }
  ];
}
