{
  system = "x86_64-linux";
  profile = "vm";
  hasFingerprint = false;
  networkingHostName = "vm";
  driverProfile = "vm";

  install = {
    diskMode = "deferred";
    targetDisk = null;
    swapSizeGiB = 4;
  };
}
