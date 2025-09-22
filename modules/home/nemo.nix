{ pkgs, ... }:
{
  home.packages = with pkgs; [
    nemo
  ];

  services.udiskie = {
    enable = true;
    settings = {
        # workaround for
        # https://github.com/nix-community/home-manager/issues/632
        program_options = {
            file_manager = "${pkgs.nemo}/bin/nemo";
        };
    };
};
}