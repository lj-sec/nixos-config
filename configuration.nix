{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      /etc/nixos/hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
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
  };

  networking = {
    hostName = "t14g5-nixos";
    networkmanager.enable = true;
  };

  i18n.defaultLocale = "en_US.UTF-8";

  time.timeZone = "America/New_York";

  services.printing.enable = true;

  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  # Define a user account.
  users.users.curse = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
  };

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    vim
    curl
    wget
    acpi
    git
    btop
    nettools
    git
  ];

  nix = {
    extraOptions = "experimental-features = nix-command flakes";
  };

  system.stateVersion = "25.05";

}

