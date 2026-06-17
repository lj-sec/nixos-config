{
  system = "x86_64-linux";
  profile = "desktop";
  hasFingerprint = false;
  networkingHostName = "desktop";
  driverProfile = "nvidia";

  install = {
    diskMode = "deferred";
    targetDisk = null;
    swapSizeGiB = 80;
  };
}
