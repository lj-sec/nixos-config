{ inputs, installSecurity ? {}, lib, pkgs, ... }:
let
  secureBoot = installSecurity.secureBoot or false;
in
{
  imports = [
    inputs.nixos-boot.nixosModules.default
  ] ++ lib.optionals secureBoot [
    inputs.lanzaboote.nixosModules.lanzaboote
  ];

  environment.systemPackages = lib.optionals secureBoot [
    pkgs.sbctl
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages;
    consoleLogLevel = 3;
    
    kernelParams = [
      "quiet" "loglevel=3" "udev.log_priority=3" "vt.global_cursor_default=0"
    ];

    loader = {
      systemd-boot = {
        enable = if secureBoot then lib.mkForce false else true;
        configurationLimit = 5;
      };
      efi = {
        canTouchEfiVariables = true;
      };
      timeout = 10;
    };
    plymouth.enable = true;
  } // lib.optionalAttrs secureBoot {
    lanzaboote = lib.mkIf secureBoot {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
    };
  };

  nixos-boot = {
    enable = true;
    theme  = "catppuccin-blue-nixos";
    # duration = 3.0;
    bgColor = { red = 0; green = 0; blue = 0; };
  };
}
