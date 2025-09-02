{ ... }:
let
  browser = "brave";
  terminal = "kitty";
in {
  wayland.windowManager.hyprland = {
    settings = {

      exec-once = [
        "dbus-update-activation-environment --all --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
        "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
        "waybar &"
        "swaync &"
        "swww-daemon &"
        "wl-clip-persist --clipboard both &"
        "hyprctl setcursor Bibata-Modern-Ice 24 &"
        "hyprlock"
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
        "col.active_border" = "rgb(98971A) rgb(CC241D) 45deg";
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
        middle_click_paste = true;
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
          ignore_window = true;
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
          "workspaces, 1, 4, easeOutCubic, fade"
        ];
      };


      binds = {
        movefocus_cycles_fullscreen = true;
      };

      bind = [
        "$mainMod, Return, exec, ${terminal}"
        "$mainMod, B, exec, ${browser}"
        "$mainMod, Q, killactive,"
        "$mainMod, F, fullscreen, 0"
        "$mainMod SHIFT, F, fullscreen, 1"
        "$mainMod, D, exec, rofi -show drun || pkill rofi"
        "$mainMod, Escape, exec, hyprlock"
        "$mainMod, C, exec, hyprpicker -a"

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

      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];

      windowrule = [
        "float,title:^(Picture-in-Picture)$"
        "pin,title:^(Picture-in-Picture)$"
      ];
      
      monitor = [ "=,preferred,auto,auto" ];

      xwayland = {
        force_zero_scaling = true;
      };
    };

  };

}
