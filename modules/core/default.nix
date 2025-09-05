{ ... }:
{
  imports = [
    ./bootloader.nix
    ./home.nix
    ./network.nix
    ./pipewire.nix
    ./services.nix
    ./system.nix
    ./wayland.nix
    ./virtualization.nix
    ./steam.nix
    ./security.nix
  ];
}
