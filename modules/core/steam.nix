{ pkgs, username, ... }:
{
  programs.steam = {
    enable = true;
    extraCompatPackages = [ pkgs.proton-ge-bin ];
    gamescopeSession.enable = true;
  };

  programs.gamescope = {
    enable = true;
    capSysNice = true;
    args = [
      "--rt"
      "--expose-wayland"
    ];
  };
  hardware.xone.enable = true; # support for the xbox controller USB dongle
}