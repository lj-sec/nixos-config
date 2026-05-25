{ lib, installFeatures ? {}, ... }:
let
  feature = name:
    if builtins.hasAttr name installFeatures then installFeatures.${name} else true;
in
{
  # Firmware updates
  services.fwupd.enable = true;

  # Btrfs: periodic scrub if you’re on Btrfs (comment out if not)
  services.btrfs.autoScrub = lib.mkIf (feature "btrfsScrub") {
    enable = true;
    interval = "weekly";
    fileSystems = [ "/" ];
  };

  # Journald size cap so logs don't balloon
  services.journald.extraConfig = ''
    SystemMaxUse=750M
    RuntimeMaxUse=250M
  '';

  # Optional: auto gc nix store weekly
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  services.udisks2.enable = true;
}
