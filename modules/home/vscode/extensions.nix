{ pkgs, ... }:
let
  theme = "";
in
{
  programs.vscode.profiles.default = {
    extensions = with pkgs.vscode-extensions; [
      
    ];
  };
}
