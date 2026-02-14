{
  description = "My NixOS Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-colors.url = "github:Misterio77/nix-colors";
    nixos-boot.url = "github:lj-sec/nixos-boot";

    catppuccin.url = "github:catppuccin/nix";
    
    home-manager = {
      url = "github:nix-community/home-manager/master";
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
    };

    lib = nixpkgs.lib;

  in {
    nixosConfigurations = {
      t14g5-nixos = lib.nixosSystem {
        inherit system;
        modules = [
          ./hosts/t14g5-nixos
        ];
        specialArgs = {
          hasFingerprint = true;
          host = "t14g5-nixos";
          inherit self inputs username;
        };
      };
      omen30l-nixos = lib.nixosSystem {
        inherit system;
        modules = [
          ./hosts/omen30l-nixos 
        ];
        specialArgs = {
          hasFingerprint = false;
          host = "omen30l-nixos";
          inherit self inputs username;
        };
      };
      precision3640-nixos = lib.nixosSystem {
        inherit system;
        modules = [
         ./hosts/precision3640-nixos
        ];
        specialArgs = {
          hasFingerprint = false;
          host = "precision3640-nixos";
          inherit self inputs username;
        };
      };
    };
  };
}
