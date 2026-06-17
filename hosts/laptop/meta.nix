{
  system = "x86_64-linux";
  profile = "laptop";
  hasFingerprint = true;
  networkingHostName = "laptop";
  driverProfile = "amd";

  install = {
    diskMode = "deferred";
    targetDisk = null;
    swapSizeGiB = 20;
  };
}
