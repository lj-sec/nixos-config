{ lib, pkgs, hasFingerprint ? false, ... }:
let
  base = {
    services.dbus.enable = true;
    security.polkit.enable = true;
    services.fwupd.enable = true;
  };

  fp = lib.mkIf hasFingerprint {
    services.fprintd.enable = true;

    security.pam.services = {
      login.fprintAuth = true;
      sudo.fprintAuth = true;
      "polkit-1".fprintAuth = true;
      hyprlock.fprintAuth = true;
    };

    environment.systemPackages = with pkgs; [ fprintd libfprint pamtester ];
  };
in
lib.mkMerge [ base fp ]