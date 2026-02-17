{ pkgs, lib, ... }:

let
  # pick your accent
  accent = "lavender";
  variant = "mocha";

  ctpKvantum = pkgs.catppuccin-kvantum.override {
    inherit accent variant;
  };

  # Kvantum theme directory names look like "Catppuccin-Mocha-Lavender"
  themeName =
    "Catppuccin-"
    + (lib.strings.toUpper (builtins.substring 0 1 variant)) + (builtins.substring 1 (builtins.stringLength variant - 1) variant)
    + "-"
    + (lib.strings.toUpper (builtins.substring 0 1 accent)) + (builtins.substring 1 (builtins.stringLength accent - 1) accent);

  # Generate kvantum.kvconfig as a file in the Nix store (a path/derivation)
  kvCfg = (pkgs.formats.ini { }).generate "kvantum.kvconfig" {
    General.theme = themeName;
  };
in
{
  home.packages = with pkgs; [
    # Wayland plugin(s) so Qt apps behave under hyprland
    qt6Packages.qtwayland
    qt5.qtwayland
    xcb-util-cursor

    # Kvantum + Catppuccin theme
    kdePackages.qtstyleplugin-kvantum
    ctpKvantum
  ];

  qt = {
    enable = true;
    platformTheme.name = "qtct";   # uses qt5ct/qt6ct to apply settings
    style.name = "kvantum";        # installs kvantum style plugins for Qt5/Qt6

    # Optional but recommended: make qt5ct/qt6ct consistent + use portals for dialogs on Wayland
    qt5ctSettings = {
      Appearance = {
        style = "kvantum";
        standard_dialogs = "xdgdesktopportal";
      };
    };
    qt6ctSettings = {
      Appearance = {
        style = "kvantum";
        standard_dialogs = "xdgdesktopportal";
      };
    };
  };

  # Make the Catppuccin Kvantum theme visible under ~/.config/Kvantum/
  xdg.configFile."Kvantum/${themeName}".source =
    "${ctpKvantum}/share/Kvantum/${themeName}";

  # Apply it by default (no GUI clicking needed)
  # NOTE: .text must be a string; the generator returns a store path, so use .source instead.
  xdg.configFile."Kvantum/kvantum.kvconfig".source = kvCfg;
}
