{ config, inputs, installSecurity ? {}, lib, pkgs, ... }:
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
      "systemd.show_status=false" "rd.systemd.show_status=false"
    ];

    loader = {
      systemd-boot = {
        enable = if secureBoot then lib.mkForce false else true;
        configurationLimit = 5;
      };
      efi = {
        canTouchEfiVariables = true;
      };
      # Hold Space during boot to show the menu and select an older generation.
      timeout = 0;
    };
    plymouth.enable = true;
  } // lib.optionalAttrs secureBoot {
    lanzaboote = lib.mkIf secureBoot {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
    };
  };

  # Leave the last splash frame visible until the compositor takes over.
  systemd.services.plymouth-quit.serviceConfig.ExecStart = [
    ""
    "-${config.boot.plymouth.package}/bin/plymouth quit --retain-splash"
  ];

  nixos-boot = {
    enable = true;
    theme  = "catppuccin-blue-nixos";
    # duration = 3.0;
    bgColor = { red = 0; green = 0; blue = 0; };
  };
}
