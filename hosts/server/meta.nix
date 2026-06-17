{
  system = "x86_64-linux";
  profile = "server";
  hasFingerprint = false;
  networkingHostName = "server";
  driverProfile = "none";

  install = {
    diskMode = "deferred";
    targetDisk = null;
    swapSizeGiB = 8;
  };
}
