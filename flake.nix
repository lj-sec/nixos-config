{
  description = "My NixOS Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland.url = "github:hyprwm/Hyprland";

    hypr-contrib = {
      url = "github:hyprwm/contrib";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprpicker = {
      url = "github:hyprwm/hyprpicker";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    hyprlock = {
      url = "github:hyprwm/hyprlock";
      inputs = {
        hyprgraphics.follows = "hyprland/hyprgraphics";
        hyprlang.follows = "hyprland/hyprlang";
        hyprutils.follows = "hyprland/hyprutils";
        nixpkgs.follows = "nixpkgs";
        systems.follows = "hyprland/systems";
      };
    };

  };

  outputs = { self, nixpkgs, ... }@inputs:

  let
    username = "curse";
    system = "x86_64-linux";

    pkgs = import nixpkgs {
      inherit system;
      # config.allowUnfree = true;
    };

    lib = nixpkgs.lib;

  in {
    nixosConfigurations = {
      t14g5-nixos = lib.nixosSystem {
        inherit system;
        modules = [ ./hosts/t14g5-nixos ];
        specialArgs = {
          host = "t14g5-nixos";
          inherit self inputs username;
        };
      };
    };
  };
}
