{ ... }:
{
  imports = [
    # Base16 palette bridge for custom CSS/Nix surfaces not covered by Catppuccin.
    ./nix-colors.nix
    # Fonts implemented throughout
    ./fonts.nix
    # GTK theming for apps that support it + cursor
    ./gtk.nix
    # QT theming
    ./qt.nix
    # Official Catppuccin modules are the source of truth for supported apps.
    ./catppuccin.nix
    # Any other session variables that may need to be set directly
    ./variables.nix
  ];
}
