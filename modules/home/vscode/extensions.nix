{ pkgs, lib, ... }:
{
  programs.vscode.profiles.default = lib.mkForce {
    extensions = with pkgs.vscode-extensions; [
      jnoortheen.nix-ide
      catppuccin.catppuccin-vsc
      catppuccin.catppuccin-vsc-icons
    ];
  };
}