{ inputs, pkgs, lib, username, host, hasFingerprint, installFeatures ? {}, ... }:
let
  feature = name:
    if builtins.hasAttr name installFeatures then installFeatures.${name} else true;
in
{

  imports = [ inputs.home-manager.nixosModules.home-manager ];
   
  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    extraSpecialArgs = { inherit inputs username host hasFingerprint installFeatures; };
    users.${username} = {
      imports = [ ./../home ];
      home = {
        username = "${username}";
        homeDirectory = "/home/${username}";
        stateVersion = "25.11";
      };
      programs.home-manager.enable = true;
    };
    backupFileExtension = "hm-bak";
  };

  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "seat" ]
      ++ lib.optional (feature "networkExtras") "wireshark";
  };
  nix.settings.allowed-users = [ "${username}" ];

  users.groups.utmp = { }; 
}
