{ pkgs, config, ... }:
{
  imports = [
    ./swap.nix
    ./hardware-configuration.nix
    ./../../modules/core
  ];

  boot.kernelModules = [ "thinkpad_acpi" ];

  # Expose all Fn hotkeys
  boot.extraModprobeConfig = ''
    options thinkpad_acpi hotkey=enable,0xffff
  '';

  environment.systemPackages = with pkgs; [
    acpi
    brightnessctl
    cpupower-gui
    linuxPackages.cpupower
    powertop
  ];
}