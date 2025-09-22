{ pkgs, config, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./../../modules/core
  ];

  boot.kernelModules = [ "thinkpad_acpi" ];

  # Expose all Fn hotkeys
  boot.extraModprobeConfig = ''
    options thinkpad_acpi hotkey=enable,0xffff
  '';

  services.dbus.enable = true;

  services.cpupower-gui.enable = true;

  environment.systemPackages = with pkgs; [
    acpi
    brightnessctl
    cpupower-gui
    linuxPackages.cpupower
    powertop
  ];
}