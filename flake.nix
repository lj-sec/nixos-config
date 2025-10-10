{
  description = "My NixOS Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-colors.url = "github:Misterio77/nix-colors";

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
      # config.allowUnfree = true;
    };

    lib = nixpkgs.lib;

  in {
    overlays = {
      waybar-lyric-fix = final: prev: {
        waybar-lyric = prev.waybar-lyric.overrideAttrs (_: {
          src = prev.fetchFromGitHub {
            owner = "Nadim147c";
            repo  = "waybar-lyric";
            rev   = "v0.11.0";
            hash  = "sha256-4qQ2b9xLcuqiN1U2AYDXEoaqWvy/o+MgTF3Zh0YPLCo=";
          };
        });
      };
    };
    nixosConfigurations = {
      t14g5-nixos = lib.nixosSystem {
        inherit system;
        modules = [ 
          { nixpkgs.overlays = [ self.overlays.waybar-lyric-fix ]; }
          ./hosts/t14g5-nixos
        ];
        specialArgs = {
          host = "t14g5-nixos";
          inherit self inputs username;
        };
      };
      omen30l-nixos = lib.nixosSystem {
        inherit system;
        modules = [
          { nixpkgs.overlays = [ self.overlays.waybar-lyric-fix ]; }
          ./hosts/omen30l-nixos 
        ];
        specialArgs = {
          host = "omen30l-nixos";
          inherit self inputs username;
        };
      };
    };
  };
}
