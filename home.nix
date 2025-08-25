{ inputs, outputs, lib, config, pkgs, ... }: {

  imports = [];

  home = {
    username = "curse";
    homeDirectory = "/home/curse";
  };

  # Programs
  programs.home-manager.enable = true;

  home.stateVersion = "25.05";
}
