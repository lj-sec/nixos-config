{ ... }:
{
  # Firmware updates
  services.fwupd.enable = true;

  # Btrfs: periodic scrub if you’re on Btrfs (comment out if not)
  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
    # fileSystems = [ "/" "/home" ]; # optionally specify
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
}