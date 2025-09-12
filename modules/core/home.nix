{ inputs, pkgs, username, host, ... }: {

  imports = [ inputs.home-manager.nixosModules.home-manager ];
   
  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    extraSpecialArgs = { inherit inputs username host; };
    users.${username} = {
      imports = [ ./../home ];
      home = {
        username = "${username}";
        homeDirectory = "/home/${username}";
        stateVersion = "25.11";
      };
      programs.home-manager.enable = true;
    };
  };

  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "wireshark" ];
  };
  nix.settings.allowed-users = [ "${username}" ];
}
