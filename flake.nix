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
    lib = nixpkgs.lib;
    usernameFromEnv = builtins.getEnv "NIXOS_CONFIG_USERNAME";
    username = if usernameFromEnv != "" then usernameFromEnv else "curse";
    featuresFromEnv = builtins.getEnv "NIXOS_CONFIG_FEATURES";
    selectedFeatures =
      if featuresFromEnv == "" then null
      else if featuresFromEnv == "__none__" then [ ]
      else builtins.filter (feature: feature != "") (lib.splitString "," featuresFromEnv);
    featureEnabled = feature:
      selectedFeatures == null || builtins.elem feature selectedFeatures;
    installFeatures = {
      bluetooth = featureEnabled "bluetooth";
      brave = featureEnabled "brave";
      btrfsScrub = featureEnabled "btrfsScrub";
      communication = featureEnabled "communication";
      devops = featureEnabled "devops";
      flatpak = featureEnabled "flatpak";
      fun = featureEnabled "fun";
      kali = featureEnabled "kali";
      mail = featureEnabled "mail";
      media = featureEnabled "media";
      music = featureEnabled "music";
      networkExtras = featureEnabled "networkExtras";
      office = featureEnabled "office";
      pass = featureEnabled "pass";
      phones = featureEnabled "phones";
      power = featureEnabled "power";
      printing = featureEnabled "printing";
      proxy = featureEnabled "proxy";
      remote = featureEnabled "remote";
      security = featureEnabled "security";
      ssh = featureEnabled "ssh";
      steam = featureEnabled "steam";
      syncthing = featureEnabled "syncthing";
      virtualization = featureEnabled "virtualization";
      vscode = featureEnabled "vscode";
    };
    system = "x86_64-linux";

    pkgs = import nixpkgs {
      inherit system;
    };

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
          inherit self inputs username installFeatures;
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
          inherit self inputs username installFeatures;
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
          inherit self inputs username installFeatures;
        };
      };
    };
  };
}
