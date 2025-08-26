{ pkgs, inputs, ... }:
{
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
    };
  };

  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
    git
  ];

  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";
  # nixpkgs.config.allowUnfree = true;
  system.stateVersion = "25.05";
}
