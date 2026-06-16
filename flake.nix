{
  description = "My NixOS Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nix-colors.url = "github:Misterio77/nix-colors";
    nixos-boot.url = "github:lj-sec/nixos-boot";

    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ... }@inputs:
  let
    lib = nixpkgs.lib;
    hostsDir = ./hosts;
    hostNames =
      builtins.attrNames
        (lib.filterAttrs (_: type: type == "directory") (builtins.readDir hostsDir));

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

    hostDefaults = {
      t14g5-nixos = {
        system = "x86_64-linux";
        profile = "laptop";
        hasFingerprint = true;
      };
      omen30l-nixos = {
        system = "x86_64-linux";
        profile = "desktop";
        hasFingerprint = false;
      };
    };

    hostMeta = host:
      let
        metaPath = hostsDir + "/${host}/meta.nix";
      in
      (hostDefaults.${host} or { })
      // (if builtins.pathExists metaPath then import metaPath else { });

    mkHost = host:
      let
        meta = hostMeta host;
        system = meta.system or "x86_64-linux";
        hasFingerprint = meta.hasFingerprint or false;
        hostProfile = meta.profile or "desktop";
      in
      lib.nixosSystem {
        inherit system;
        modules = [
          (hostsDir + "/${host}")
        ];
        specialArgs = {
          inherit self inputs username installFeatures hasFingerprint host hostProfile;
          hostMeta = meta;
        };
      };
  in {
    nixosConfigurations = lib.genAttrs hostNames mkHost;
  };
}
