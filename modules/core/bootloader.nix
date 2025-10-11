{ inputs, pkgs, ... }:
{
  imports = [
    inputs.nixos-boot.nixosModules.default
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    consoleLogLevel = 3;
    
    kernelParams = [
      "quiet" "loglevel=3" "udev.log_priority=3" "vt.global_cursor_default=0"
    ];

    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 5;
      };
      efi = {
        canTouchEfiVariables = true;
      };
      timeout = 10;
    };
    plymouth.enable = true;
  };

  nixos-boot = {
    enable = true;
    theme  = "evil-nixos-centered";   # <- pick the theme here
    # duration = 3.0;          # optional: force minimum seconds to show splash
    bgColor = { red = 0; green = 0; blue = 0; };  # tweak background
  };
}