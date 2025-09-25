{ pkgs, ... }:
{
  home.packages = with pkgs; [
    pass
  ];

  programs.gpg.enable = true;
  
  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 3600;
    enableSshSupport = false;
    pinentryPackage = pkgs.pinentry-gnome3;
  };

  programs.password-store = {
    enable = true;
    package = pkgs.pass;
  };
}