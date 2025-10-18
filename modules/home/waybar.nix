{ config, username, ... }:
let
  p = config.colorScheme.palette; 
  custom = {
    font = "0xProto Nerd Font";
    size_launcher = "20px";
    font_size    = "16px";
    font_weight  = "Bold";
    text_color   = "#${p.base05}";
    background_0 = "#${p.base00}";
    background_1 = "#${p.base01}";
    border_color = "#${p.base03}";
    red     = "#${p.base08}";
    orange  = "#${p.base09}";
    yellow  = "#${p.base0A}";
    green   = "#${p.base0B}";
    cyan    = "#${p.base0C}";
    blue    = "#${p.base0D}";
    magenta = "#${p.base0E}";
    brown   = "#${p.base0F}";
    opacity = "1";
    indicator_height = "2px";
  };
in
{
  programs.waybar = {

    enable = true;
    style = with custom; ''
      
      /* Affecting the whole bar */
      * {
        font-family: "${font}";
        font-weight: ${font_weight};
        font-size: ${font_size};
        opacity: ${opacity};
        min-height: 0;
      }
      window#waybar {
        background: ${background_1};
      }
      #custom-lyrics, #cpu, #memory, #network, #battery, #custom-mic, #pulseaudio, #custom-swaync, #custom-power {
        background: ${background_0};
        margin: 3px 2px;
        padding: 4px 8px;
        border-radius: 10px;
      }

      /* Modules from left to right: */

      /* Snowflake launcher */
      #custom-launcher {
        font-size: ${size_launcher};
        margin-left: 15px;
        padding-right: 10px;
      }

      /* Hyprland workspaces */
      #workspaces {
        padding-left: 15px;
      }
      #workspaces button {
        color: ${yellow};
        padding-left: 5px;
        padding-right: 5px;
        margin-right: 10px;
      }
      #workspaces button.empty {
        color: ${text_color};
      }
      #workspaces button.active {
        color: ${orange};
      }

      /* Clock and tray bars */
      #clock, #tray {
        background: ${background_0};
        margin: 3px 2px;
        padding: 4px 8px;
        border-radius: 10px;
        border: 1px solid ${border_color};
      }

      /* Spotify songs and lyrics */
      #custom-lyrics {
        margin: 0 6px;
        padding: 0 10px;
        box-shadow: inset 3px 0 0 0 ${green},
                    inset -3px 0 0 0 ${green};
      }
      #custom-lyrics.paused {
        opacity: 0.7;
      }
      #custom-lyrics:hover  {
        box-shadow: inset 4px 0 0 0 ${green},
                    inset -4px 0 0 0 ${green};
      }

      /* CPU Pill */
      #cpu                  { box-shadow: inset 3px 0 0 0 ${red},
                                          inset -3px 0 0 0 ${red}; }
      #cpu:hover            { box-shadow: inset 4px 0 0 0 ${red},
                                          inset -4px 0 0 0 ${red}; }

      /* RAM Pill */
      #memory               { box-shadow: inset 3px 0 0 0 ${cyan},
                                          inset -3px 0 0 0 ${cyan}; }
      #memory:hover         { box-shadow: inset 4px 0 0 0 ${cyan},
                                          inset -4px 0 0 0 ${cyan}; }
      
      /* Networking pill with multiple states */
      #network              { box-shadow: inset 3px 0 0 0 ${magenta},
                                          inset -3px 0 0 0 ${magenta}; }
      #network:hover        { box-shadow: inset 4px 0 0 0 ${magenta},  
                                          inset -4px 0 0 0 ${magenta}; }
      #network.disconnected       { box-shadow: inset 3px 0 0 0 ${red},
                                                inset -3px 0 0 0 ${red}; }
      #network.disconnected:hover { box-shadow: inset 4px 0 0 0 ${red},    
                                                inset -4px 0 0 0 ${red}; }
      #network.disabled           { box-shadow: inset 3px 0 0 0 ${border_color},
                                                inset -3px 0 0 0 ${border_color}; }
      #network.disabled:hover     { box-shadow: inset 4px 0 0 0 ${border_color},
                                                inset -4px 0 0 0 ${border_color}; }
      
      /* Battery pill with multiple states */
      #battery              { box-shadow: inset 3px 0 0 0 ${yellow},
                                          inset -3px 0 0 0 ${yellow}; }
      #battery:hover        { box-shadow: inset 4px 0 0 0 ${yellow},
                                          inset -4px 0 0 0 ${yellow}; }
      #battery.full, #battery.charging                { box-shadow: inset 3px 0 0 0 ${green},
                                                                    inset -3px 0 0 0 ${green}; }
      #battery.full:hover, #battery.charging:hover    { box-shadow: inset 4px 0 0 0 ${green},
                                                                    inset -4px 0 0 0 ${green}; }
      #battery.warning, #battery.critical             { box-shadow: inset 3px 0 0 0 ${red},
                                                                    inset -3px 0 0 0 ${red};   }
      #battery.warning:hover, #battery.critical:hover { box-shadow: inset 4px 0 0 0 ${red},
                                                                    inset -4px 0 0 0 ${red};   }
      
      /* Custom mic module to ensure state updates properly */
      #custom-mic {
        padding-left: 8px;
        box-shadow: inset 3px 0 0 0 ${blue};
      }
      #custom-mic:hover     { box-shadow: inset 4px 0 0 0 ${blue};   }

      /* Audio pill */
      #pulseaudio           { box-shadow: inset -3px 0 0 0 ${blue};  }
      #pulseaudio:hover     { box-shadow: inset -4px 0 0 0 ${blue};  }
      
      /* Notification launcher */
      #custom-swaync        { box-shadow: inset 3px 0 0 0 ${orange}; }
      #custom-swaync:hover  { box-shadow: inset 4px 0 0 0 ${orange}; }
      
      /* Wlogout screen launcher */
      #custom-power {
        padding-left: 3px;
        padding-right: 10px;
        box-shadow: inset -3px 0 0 0 ${orange};
      }
      #custom-power:hover   { box-shadow: inset -4px 0 0 0 ${orange}; }
    '';

    settings.mainBar = with custom; {
      position = "top";
      layer = "top";
      height = 20;
      margin-top = 0;
      margin-bottom = 0;
      margin-right = 0;
      modules-left = [
        "custom/launcher"
        "hyprland/workspaces"
        "clock"
        "tray"
      ];
      modules-center = [
        "custom/lyrics"
      ];
      modules-right = [
        "cpu"
        "memory"
        "custom/mic"
        "pulseaudio"
        "network"
        "battery"
        "custom/swaync"
        "custom/power"
      ];
      clock = {
        format = " {:%H:%M}";
        format-alt = " {:%m/%d}";
        tooltip = true;
        tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
        calendar = {
          format = {
            today = "<span color='${yellow}'><b>{}</b></span>";
          };
        };
        on-click-right = "hyprctl dispatch exec '[float; center; size 950 650] gnome-calendar'";
      };
      "hyprland/workspaces" = {
        active-only = false;
        disable-scroll = true;
        format = "{icon}";
        on-click = "activate";
        sort-by-number = true;
        format-icons = {
          "1" = "I";
          "2" = "II";
          "3" = "III";
          "4" = "IV";
          "5" = "V";
          "6" = "VI";
          "7" = "VII";
          "8" = "VIII";
          "9" = "IX";
          "10" = "X";
        };
        persistent-workspaces = {
          "1" = [ ];
          "2" = [ ];
          "3" = [ ];
          "4" = [ ];
          "5" = [ ];
        };
      };
      cpu = {
        format = "<span foreground='${red}'> </span> {usage}%";
        format-alt = "<span foreground='${red}'> </span> {avg_frequency} GHz";
        interval = 2;
        on-click-right = "hyprctl dispatch exec '[float; center; size 950 650] kitty --title float_kitty btop'";
      };
      memory = {
        format = "<span foreground='${cyan}'> </span> {}%";
        format-alt = "<span foreground='${cyan}'> </span> {used} GiB";
        interval = 2;
        on-click-right = "hyprctl dispatch exec '[float; center; size 950 650] kitty --title float_kitty btop'";
      };
      network = {
        format-wifi = "<span foreground='${magenta}'> </span> {signalStrength}%";
        format-ethernet = "<span foreground='${magenta}'>󰈀 </span>";
        tooltip-format = "Connected to {essid} {ifname} via {gwaddr}";
        format-linked = " {ifname} (No IP)";
        format-disconnected = "<span foreground='${red}'>󰌙 </span>";
        on-click = "hyprctl dispatch exec '[float; center; size 950 650] kitty --title float_kitty nmtui'";
      };
      tray = {
        icon-size = 15;
        spacing = 10;
      };
      "pulseaudio" = {
        format = "<span foreground='${blue}'> </span>{volume}%";
        format-muted = "<span foreground='${blue}'> </span>{volume}%";
        scroll-step = 2;
        on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        on-click-right = "hyprctl dispatch exec '[float; center; size 950 650] pavucontrol'";
      };
      "custom/mic" = {
        return-type = "json";
        interval = 1;
        tooltip = true;
        exec = ''
          bash -c '
            s=$(wpctl get-volume @DEFAULT_SOURCE@ 2>/dev/null || true)

            # Parse volume and mute
            vol=$(printf "%s" "$s" | awk "{for(i=1;i<=NF;i++) if(\$i ~ /^[0-9.]+$/) v=\$i} END {if(v==\"\" ) v=0; printf(\"%.0f\", v*100)}")
            if printf "%s" "$s" | grep -q MUTED; then
              icon="<span foreground=\"${custom.blue}\"></span>"
              status="muted"
            else
              icon="<span foreground=\"${custom.blue}\"></span>"
              status="live"
            fi

            # Friendly mic name (fallback to node.name)
            mic_name=$(wpctl inspect @DEFAULT_SOURCE@ 2>/dev/null | sed -n "s/.*\"node.description\" = \"\\(.*\\)\".*/\\1/p")
            [ -z "$mic_name" ] && mic_name=$(wpctl inspect @DEFAULT_SOURCE@ 2>/dev/null | sed -n "s/.*\"node.name\" = \"\\(.*\\)\".*/\\1/p")

            text="$icon ${vol}%"
            tooltip="🎙 $mic_name\nStatus: $status\nVolume: ${vol}%"

            printf "{\\"text\\": \\"%s\\", \\"tooltip\\": \\"%s\\"}\n" "$text" "$tooltip"
          '
        '';
        format = "{}";
        on-click = "wpctl set-mute @DEFAULT_SOURCE@ toggle";
        on-click-right = "hyprctl dispatch exec '[float; center; size 950 650] pavucontrol'";
      };
      battery = {
        format =              "<span foreground='${yellow}'>󰁹</span> {capacity}%";
        format-charging =     "<span foreground='${green}'>󰂄</span> {capacity}%";
        format-full =         "<span foreground='${green}'>󰂅</span> {capacity}%";
        format-almost =       "<span foreground='${yellow}'>󰂂</span> {capacity}%";
        format-threequarter = "<span foreground='${yellow}'>󰂀</span> {capacity}%";
        format-half =         "<span foreground='${yellow}'>󰁾</span> {capacity}%";
        format-quarter =      "<span foreground='${yellow}'>󰁻</span> {capacity}%";
        format-warning =      "<span foreground='${red}'>󰂎 </span>{capacity}%";
        format-critical =     "<span foreground='${red}'>󰂎!</span>{capacity}%";
        interval = 5;
        states = {
          full = 100;
          almost = 99;
          threequarter = 75;
          half = 50;
          quarter = 25;
          warning = 10;
          critical = 5;
        };
        format-time = "Time Left: {H}h{M}m";
        tooltip = true;
        tooltip-format = "{time}";
        on-click = "hyprctl dispatch exec '[float; center; size 950 650] cpupower-gui'";
      };
      "custom/launcher" = {
        format = "";
        on-click = "rofi -show drun || pkill rofi";
        tooltip = true;
        tooltip-format = "Run Rofi";
      };
      "custom/swaync" = {
        format = "";
        on-click = "sh -c 'sleep 0.1; swaync-client -t -sw'";
        on-click-right = "swaync-client -C";
      };
      "custom/lyrics" = {
        return-type = "json";
        format = "<span foreground='${green}'>󰐎  </span> {text}";
        format-alt = "<span foreground='${green}'>󰐎  </span> {text}";
        hide-empty-text = true;
        escape = true;
        tooltip = false;
        exec-if = "which waybar-lyric";
        exec = "waybar-lyric --quiet -m150";
        on-click = "waybar-lyric --toggle";
      };
      "custom/power" = {
        format = "";
        tooltip = true;
        tooltip-format = "Power menu";
        on-click = "wlogout -b 3 -n -P 0 -T 250 -B 250 -L 500 -R 500";
      };
    }; 
  };
}
