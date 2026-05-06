{ pkgs, ... }:
{
  services.usbmuxd.enable = true;

  environment.systemPackages = with pkgs; [
    libimobiledevice
    ifuse
    kdePackages.kio-extras # useful for Dolphin/KDE
  ];
}