{ config, pkgs, ... }:
let
  p = config.colorScheme.palette;
  browser = "brave";
  terminal = "kitty";
  ssDir="${config.home.homeDirectory}/Pictures/Screenshots";
in
{

  home.file.".config/hypr/autostart.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail
      hyprlock                     # blocks until unlocked
      waybar &                     # start the rest after unlock
      swaync &
      swww-daemon &
      hyprctl dispatch exec "[workspace 5 silent] spotify" # waybar-lyric eats cpu unless spotify is launched
      wl-clip-persist --clipboard both &
    '';
  };

  wayland.windowManager.hyprland = {
    settings = {

      exec-once = [
        "dbus-update-activation-environment --all --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
        "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
        "$HOME/.config/hypr/autostart.sh"
      ];

      input = {
        kb_layout = "us";
        numlock_by_default = true;
        repeat_delay = 300;
        touchpad = {
          natural_scroll = true;
        };
      };

      general = {
        "$mainMod" = "SUPER";
        layout = "dwindle";
        gaps_in = 3;
        gaps_out = 3;
        border_size = 1;
        "col.active_border" = "rgb(${p.base08}) rgb(${p.base00}) 45deg";
        "col.inactive_border" = "0x00000000";
        # border_part_of_window = false;
        no_border_on_floating = false;
      };

      misc = {
        disable_autoreload = true;
        disable_hyprland_logo = true;
        layers_hog_keyboard_focus = true;
        animate_manual_resizes = true;
        enable_swallow = true;
        focus_on_activate = false; # may be weird
        new_window_takes_over_fullscreen = 2;
        middle_click_paste = false;
      };

      dwindle = {
        force_split = 0;
        special_scale_factor = 1.0;
        split_width_multiplier = 1.0;
        use_active_for_splits = true;
        pseudotile = "yes";
        preserve_split = "no";
      };

      master = {
        new_status = "master";
        special_scale_factor = 1;
      };

      decoration = {
        rounding = 0;
        active_opacity = 0.90;
        inactive_opacity = 0.90;
        fullscreen_opacity = 1.0;

        blur = {
          enabled = true;
          size = 3;
          passes = 1;
          contrast = 1.4;
          ignore_opacity = true;
          noise = 0;
          new_optimizations = true;
          xray = true;
        };
        
        shadow = {
          enabled = true;
          offset = "0 2";
          range = 20;
          render_power = 3;
          color = "rgba(00000055)";
        };
      };
        
      animations = {
        enabled = true;
        
        bezier = [
          "fluent_decel, 0, 0.2, 0.4, 1"
          "easeOutCirc, 0, 0.55, 0.45, 1"
          "easeOutCubic, 0.33, 1, 0.68, 1"
          "fade_curve, 0, 0.55, 0.45, 1"
        ];

        animation = [
          # Name, Enabled, Speed, Curve, Style

          # Windows
          "windowsIn, 0, 4, easeOutCubic, popin 20%"
          "windowsOut, 0, 4, fluent_decel, popin 80%"
          "windowsMove, 1, 2, fluent_decel, slide"

          # Fade
          "fadeIn, 1, 3, fade_curve" 
          "fadeOut, 1, 3, fade_curve"

          # Workspaces
          "workspaces, 1, 4, easeOutCubic, slide"
        ];
      };


      binds = {
        movefocus_cycles_fullscreen = true;
      };

      bind = [
        "$mainMod, Return, exec, ${terminal}"
        "$mainMod, B, exec, ${browser}"
        "$mainMod, Q, killactive,"
        "$mainMod, F, fullscreen, 1"
        "$mainMod SHIFT, F, fullscreen, 0"
        "$mainMod, D, exec, rofi -show drun || pkill rofi"
        "$mainMod, Escape, exec, hyprlock"
        "$mainMod, C, exec, hyprpicker -a"
        "$mainMod, T, togglefloating"
        "$mainMod, N, exec, sticky -n"

        # Screenshots
        "$mainMod, S, exec, grimblast --notify --freeze copy area"
        "$mainMod SHIFT, S, exec, grimblast --notify --freeze save area ${ssDir}"
        "$mainMod, A, exec, grimblast --notify --freeze save area - | swappy -f -"

        # Focus
        "$mainMod, h, movefocus, l"
        "$mainMod, j, movefocus, d"
        "$mainMod, k, movefocus, u"
        "$mainMod, l, movefocus, r"

        # Move Windows
        "$mainMod SHIFT, h, movewindow, l"
        "$mainMod SHIFT, j, movewindow, d"
        "$mainMod SHIFT, k, movewindow, u"
        "$mainMod SHIFT, l, movewindow, r"

        # Resize Windows
        "$mainMod CTRL, h, resizeactive, -80 0"
        "$mainMod CTRL, j, resizeactive, 0 80"
        "$mainMod CTRL, k, resizeactive, 0 -80"
        "$mainMod CTRL, l, resizeactive, 80 0"

        # Workspaces (1-10)
        "$mainMod, 1, workspace, 1" 
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"
        "$mainMod, 6, workspace, 6"
        "$mainMod, 7, workspace, 7"
        "$mainMod, 8, workspace, 8"
        "$mainMod, 9, workspace, 9"
        "$mainMod, 0, workspace, 10"
        "$mainMod SHIFT, 1, movetoworkspacesilent, 1"
        "$mainMod SHIFT, 2, movetoworkspacesilent, 2"
        "$mainMod SHIFT, 3, movetoworkspacesilent, 3"
        "$mainMod SHIFT, 4, movetoworkspacesilent, 4" 
        "$mainMod SHIFT, 5, movetoworkspacesilent, 5" 
        "$mainMod SHIFT, 6, movetoworkspacesilent, 6" 
        "$mainMod SHIFT, 7, movetoworkspacesilent, 7" 
        "$mainMod SHIFT, 8, movetoworkspacesilent, 8" 
        "$mainMod SHIFT, 9, movetoworkspacesilent, 9" 
        "$mainMod SHIFT, 0, movetoworkspacesilent, 10"

        # Mousewheel workspace nav
        "$mainMod, mouse_down, workspace, e-1"
        "$mainMod, mouse_up, workspace, e+1"
      ];

      bindl = [
        # Speaker volume (pamixer path)
        ",XF86AudioRaiseVolume,exec,pamixer -i 5"
        ",XF86AudioLowerVolume,exec,pamixer -d 5"
        ",XF86AudioMute,exec,pamixer -t"

        # Mic Mute
        ",XF86AudioMicMute,exec,wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"

        # Brightness
        ",XF86MonBrightnessUp,exec,brightnessctl set +10%"
        ",XF86MonBrightnessDown,exec,brightnessctl set 10%-"
      ];

      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];

      windowrule = [
        "float,title:^(Picture-in-Picture)$"
        "pin,title:^(Picture-in-Picture)$"
      ];

      windowrulev2 = [
        "float, class:^(?i)sticky.py$"
        "size 200 200, class:^(?i)sticky.py$"
      ];
      
      monitor = [ "eDP-1,preferred,auto,1" ];

      xwayland = {
        force_zero_scaling = true;
      };
    };
  };
}
