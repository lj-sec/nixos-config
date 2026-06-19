{
  username = "curse";
  networkingHostName = "t14g5-nixos";
  driverProfile = "amd";
  installSecurity = {
    encryption = "luks-tpm2";
    secureBoot = true;
    luksName = "cryptroot";
    luksDeviceUuid = "be125945-6ad2-4b26-b512-ffea26eb00d8";
    tpm2Pcrs = [ 7 ];
  };
  installFeatures = {
      brave = true;
      btrfsScrub = true;
      vscode = true;
      pass = true;
      communication = true;
      mail = true;
      media = true;
      music = true;
      office = true;
      fun = true;
      security = true;
      devops = true;
      remote = true;
      steam = true;
      virtualization = true;
      kali = true;
      networkExtras = true;
      syncthing = true;
      proxy = true;
      printing = true;
      bluetooth = true;
      phones = true;
      flatpak = true;
      power = true;
      ssh = true;
  };
}
