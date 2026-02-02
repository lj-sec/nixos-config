{ config, pkgs, username, ... }:

{
  services.syncthing = {
    enable = true;

    user = "${username}";
    dataDir = "/home/${username}";
    configDir = "/home/${username}/.config/syncthing";

    # opens 22000/TCP+UDP and 21027/UDP in the NixOS firewall
    openDefaultPorts = true;

    # keep the GUI local (safest); access via browser on the same machine
    guiAddress = "127.0.0.1:8384";
  };
}