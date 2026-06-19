{ inputs, ... }:
{
  imports = [
    inputs.catppuccin.homeModules.catppuccin
  ];

  catppuccin = {
    enable = true;
    autoEnable = false;
    flavor = "mocha";
    accent = "lavender";

    brave.enable = true;
    btop.enable = true;
    cava.enable = true;
    cursors.enable = true;
    fish.enable = true;
    gtk.icon.enable = true;
    hyprland.enable = false;
    hyprlock = {
      enable = true;
      useDefaultConfig = false;
    };
    kitty.enable = true;
    kvantum.enable = true;
    mpv.enable = true;
    rofi.enable = true;
    swaync.enable = true;
    thunderbird = {
      enable = true;
      profile = "main";
    };
    vesktop.enable = true;
    vscodium.profiles.default = {
      enable = true;
      icons.enable = true;
    };
    waybar.enable = true;
    wlogout.enable = true;
  };
}
