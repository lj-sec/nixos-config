{ pkgs, ... }:
{
  programs.vesktop.enable = true;

  catppuccin = {
    enable = true;
    flavor = "mocha";
    accent = "mauve";
  };

  catppuccin.vesktop.enable = true;
}