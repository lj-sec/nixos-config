{ pkgs, ... }:
{
  programs.vscode.profiles.default = {
    extensions = with pkgs.vscode-extensions; [
      jnoortheen.nix-ide
      catppuccin.catppuccin-vsc
      catppuccin.catppuccin-vsc-icons
    ];
  };
}