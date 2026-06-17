{
  description = "NixOS host configurations";

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
    hostNames = [
      "desktop"
      "laptop"
      "server"
      "vm"
    ];

    hostMeta = host:
      let
        metaPath = hostsDir + "/${host}/meta.nix";
      in
      if builtins.pathExists metaPath then import metaPath else { };

    hostLocal = host:
      let
        localPath = hostsDir + "/${host}/local.nix";
      in
      if builtins.pathExists localPath then import localPath else { };

    mkHost = host:
      let
        meta = hostMeta host;
        local = hostLocal host;
        system = meta.system or "x86_64-linux";
        hasFingerprint = meta.hasFingerprint or false;
        hostProfile = meta.profile or "desktop";
        username = local.username or meta.username or "curse";
        networkingHostName = local.networkingHostName or meta.networkingHostName or host;
        driverProfile = local.driverProfile or meta.driverProfile or "auto";
        installFeatures = local.installFeatures or { };
      in
      lib.nixosSystem {
        inherit system;
        modules = [
          (hostsDir + "/${host}")
        ];
        specialArgs = {
          inherit self inputs username installFeatures hasFingerprint host hostProfile networkingHostName driverProfile;
          hostMeta = meta;
        };
      };
  in {
    nixosConfigurations = lib.genAttrs hostNames mkHost;
  };
}
