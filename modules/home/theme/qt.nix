{ pkgs, ... }:
{
  home.packages = with pkgs; [
    qt6Packages.qtdeclarative
    qt6Packages.qtwayland
    xcb-util-cursor
  ];
}