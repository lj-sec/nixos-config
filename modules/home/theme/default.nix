{ ... }:
{
  imports = [
    # Color scheme implemented throughout
    ./nix-colors.nix
    # Fonts implemented throughout
    ./fonts.nix
    # GTK theming for apps that support it + cursor
    ./gtk.nix
    # QT theming
    ./qt.nix
    # Catppuccin
    ./catppuccin.nix
  ];
}
