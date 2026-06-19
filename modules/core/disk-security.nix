{ installSecurity ? {}, lib, ... }:
let
  encryption = installSecurity.encryption or "none";
  luksName = installSecurity.luksName or "cryptroot";
  luksDeviceUuid = installSecurity.luksDeviceUuid or null;
  tpm2Pcrs = installSecurity.tpm2Pcrs or [ 7 ];
  encrypted = encryption == "luks-passphrase" || encryption == "luks-tpm2";
  tpm2 = encryption == "luks-tpm2";
in
{
  assertions = [
    {
      assertion = builtins.elem encryption [ "none" "luks-passphrase" "luks-tpm2" ];
      message = "installSecurity.encryption must be one of: none, luks-passphrase, luks-tpm2.";
    }
    {
      assertion = !encrypted || luksDeviceUuid != null;
      message = "Encrypted installs must set installSecurity.luksDeviceUuid.";
    }
    {
      assertion = !tpm2 || (installSecurity.secureBoot or false);
      message = "installSecurity.encryption = \"luks-tpm2\" requires installSecurity.secureBoot = true.";
    }
  ];

  boot.initrd = lib.mkIf encrypted {
    luks.devices.${luksName} = {
      device = "/dev/disk/by-uuid/${luksDeviceUuid}";
    } // lib.optionalAttrs tpm2 {
      crypttabExtraOpts = [
        "tpm2-device=auto"
        "tpm2-pcrs=${lib.concatMapStringsSep "+" toString tpm2Pcrs}"
      ];
    };

    systemd = lib.mkIf tpm2 {
      enable = true;
      tpm2.enable = true;
    };
  };
}
