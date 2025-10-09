{ pkgs, ... }:
{
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
    plymouth = {
      enable = true;
      theme = "bgrt";
    };
  };
}