{ pkgs, lib, ... }:
let
  terraformFixed =
    pkgs.vscode-extensions.hashicorp.terraform.overrideAttrs (old: {
      postInstall = (old.postInstall or "") + ''
        ext="$out/share/vscode/extensions/hashicorp.terraform"

        # Some builds leave everything under ext/extension/*
        if [ -d "$ext/extension" ] && [ -f "$ext/extension/package.json" ] && [ ! -f "$ext/package.json" ]; then
          cp -a "$ext/extension/." "$ext/"
          rm -rf "$ext/extension"
        fi
      '';
    });
in
{
  programs.vscode.profiles.default = lib.mkForce {
    extensions = [
      pkgs.vscode-extensions.jnoortheen.nix-ide
      pkgs.vscode-extensions.catppuccin.catppuccin-vsc
      pkgs.vscode-extensions.catppuccin.catppuccin-vsc-icons
      terraformFixed
    ];
  };
}
