{ config, pkgs, ... }:

{
    wayland.windowManager.hyprland = {
        enable = true;
        xwayland.enable = true;
        settings = {
            "$mod" = "SUPER";
        }
        bind = [
            "SUPER+RETURN exec ${pkgs.kitty}/bin/kitty"
            "SUPER+Q killactive"
            "SUPER+D exec rofi -show drun"
            "SUPER+1 workspace 1"
            "SUPER+2 workspace 2"
            "SUPER+3 workspace 3"
            "SUPER+4 workspace 4"
            "SUPER+5 workspace 5"
            "SUPER+6 workspace 6"
            "SUPER+7 workspace 7"
            "SUPER+8 workspace 8"
            "SUPER+9 workspace 9"
            "SUPER+LEFT move left"
            "SUPER+RIGHT move right"
            "SUPER+UP move up"
            "SUPER+DOWN move down"
            "SUPER+SHIFT+LEFT swap left"
            "SUPER+SHIFT+RIGHT swap right"
            "SUPER+SHIFT+UP swap up"
            "SUPER+SHIFT+DOWN swap down"
        ];

        programs.waybar.enable = true;
        programs.waybar.settings = {
            position = "top";
            modules-left = [ "sway/workspaces" "sway/mode" "sway/window" ];
            modules-center = [ "clock" ];
            modules-right = [ "pulseaudio" "network" "cpu" "memory" "battery" "tray" ];
        };

        services.swaync.enable = true;
        services.swaync.settings = {
            workspace = 10;
            output = "eDP-1";
        };

        home.packages = with pkgs; [
            hyprland
            hyprpaper
            hyprpicker
            waybar
            swaync
            kitty
            rofi
            grim
            slurp
            wl-clipboard
            pamixer
            pavucontrol
            kitty
            brave
            ffmpegthumbnailer
            polkit-gnome
        ];
    };
}