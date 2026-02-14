{ lib, pkgs, hasFingerprint, ... }:
let
  base = {
    services.dbus.enable = true;
    security.polkit.enable = true;
    services.fwupd.enable = true;
    
    security.sudo.extraConfig = ''
      Defaults env_keep += "GIO_EXTRA_MODULES GIO_MODULE_DIR XDG_DATA_DIRS WAYLAND_DISPLAY DISPLAY XDG_RUNTIME_DIR"
    '';
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