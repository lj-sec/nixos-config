{ ... }:
{
  swapDevices = [
    {
      device = "/var/lib/swap/swapfile";
      size = 4 * 1024;
    }
  ];
}
