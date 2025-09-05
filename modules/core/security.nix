{ config, pkgs,... }:
{
  security.polkit.enable = true;
  services.fwupd.enable = true;
  services.fprintd.enable = true;

  security.pam.services = {
    login.fprintAuth = true;
    sudo.fprintAuth = true;
    "polkit-1".fprintAuth = true;
    hyprlock.fprintAuth = true;
  };

  environment.systemPackages = with pkgs; [
    fprintd
    libfprint
    pamtester
  ];
}
