{ inputs, pkgs, username, host, hasFingerprint, ... }: {

  imports = [ inputs.home-manager.nixosModules.home-manager ];
   
  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    extraSpecialArgs = { inherit inputs username host hasFingerprint; };
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
    extraGroups = [ "wheel" "networkmanager" "wireshark" "disk" "plugdev" ];
  };
  nix.settings.allowed-users = [ "${username}" ];

  users.groups.utmp = { }; 
}
