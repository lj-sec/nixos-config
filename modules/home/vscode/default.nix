{ ... }:
{
  imports = [
    # VSCodium package, keybindings
    ./vscode.nix
    # General user settings
    ./settings.nix
    # VSCodium extensions
    ./extensions.nix
  ];
}
