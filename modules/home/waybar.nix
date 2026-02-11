{ pkgs, config, username, ... }:
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

  waybarCava = pkgs.writeShellScriptBin "WaybarCava" ''
    set -euo pipefail

    if ! command -v cava >/dev/null 2>&1; then
      echo "cava not found in PATH" >&2
      exit 1
    fi

    bar="▁▂▃▄▅▆▇█"

    dict="s/;//g"
    bar_length=''${#bar}
    for ((i = 0; i < bar_length; i++)); do
      dict+=";s/$i/''${bar:$i:1}/g"
    done

    RUNTIME_DIR="''${XDG_RUNTIME_DIR:-/tmp}"
    pidfile="$RUNTIME_DIR/waybar-cava.pid"
    if [ -f "$pidfile" ]; then
      oldpid=$(cat "$pidfile" || true)
      if [ -n "''${oldpid:-}" ] && kill -0 "$oldpid" 2>/dev/null; then
        kill "$oldpid" 2>/dev/null || true
        sleep 0.1 || true
      fi
    fi
    echo $$ > "$pidfile"

    config_file=$(mktemp "''${RUNTIME_DIR}/waybar-cava.XXXXXX.conf")
    cleanup() { rm -f "$config_file" "$pidfile"; }
    trap cleanup EXIT INT TERM

    cat >"$config_file" <<EOF
    [general]
    framerate = 30
    bars = 10

    [input]
    method = pulse
    source = auto

    [output]
    method = raw
    raw_target = /dev/stdout
    data_format = ascii
    ascii_max_range = 7
    EOF

    exec cava -p "$config_file" | sed -u "$dict"
  '';
in
{
  programs.waybar = {
    enable = true;

    style = with custom; ''
      * {
        font-family: "${font}";
        font-weight: ${font_weight};
        font-size: ${font_size};
        min-height: 0;
      }

      window#waybar {
        background: transparent;
      }

      #custom-launcher,
      #workspaces,
      #clock,
      #tray,
      #custom-cava,
      #custom-lyrics,
      #cpu,
      #memory,
      #network,
      #battery,
      #custom-mic,
      #pulseaudio,
      #custom-swaync,
      #custom-power {
        background: ${background_0};
        margin: 2px 1px;
        padding: 3px 6px;
        border-radius: 8px;
        border: 1px solid ${border_color};
      }

      #workspaces button {
        color: ${yellow};
        background: transparent;
        padding: 0 6px;
        margin: 0 4px 0 0;
        border-radius: 6px;
      }
      #workspaces button.empty {
        color: ${text_color};
        opacity: 0.7;
      }
      #workspaces button.active {
        color: ${orange};
      }

      #custom-cava {
        min-width: 110px;
      }

      #custom-lyrics {
        padding-left: 8px;
        padding-right: 8px;
      }

      #custom-mic {
        margin-right: 0px;
        border-radius: 8px 0 0 8px;
        border-right: 0;
        padding-right: 2px;
      }
      #pulseaudio {
        margin-left: 0px;
        border-radius: 0 8px 8px 0;
        padding-left: 2px;
      }

      #custom-swaync {
        margin-right: 0px;
        border-radius: 8px 0 0 8px;
        border-right: 0;
        padding-right: 2px;
      }
      #custom-power {
        margin-left: 0px;
        border-radius: 0 8px 8px 0;
        padding-left: 2px;
      }

      tooltip {
        background: ${background_1};
        border: 1px solid ${border_color};
        border-radius: 8px;
      }
    '';

    settings.mainBar = with custom; {
      position = "top";
      layer = "top";
      height = 28;

      margin-top = 0;
      margin-bottom = 0;
      margin-right = 0;

      modules-left = [
        "custom/launcher"
        "hyprland/workspaces"
        "clock"
        "tray"
        "custom/cava"
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
        format = "<span foreground='${red}'>[  </span>{usage}% <span foreground='${red}'>]</span>";
        format-alt = "<span foreground='${red}'>[  </span>{avg_frequency}GHz <span foreground='${red}'>]</span>";
        interval = 2;
        on-click-right = "hyprctl dispatch exec '[float; center; size 950 650] kitty --title float_kitty btop'";
      };

      memory = {
        format = "<span foreground='${cyan}'>[  </span>{}% <span foreground='${cyan}'>]</span>";
        format-alt = "<span foreground='${cyan}'>[  </span>{used}GiB <span foreground='${cyan}'>]</span>";
        interval = 2;
        on-click-right = "hyprctl dispatch exec '[float; center; size 950 650] kitty --title float_kitty btop'";
      };

      network = {
        format-wifi = "<span foreground='${magenta}'>[  </span>{signalStrength}% <span foreground='${magenta}'>]</span>";
        format-ethernet = "<span foreground='${magenta}'>[ 󰈀 ]</span>";
        tooltip-format = "Connected to {essid} {ifname} via {gwaddr}";
        format-linked = "<span foreground='${magenta}'>[ {ifname}</span>(No IP)<span foreground='${magenta}'>]</span>";
        format-disconnected = "<span foreground='${red}'>[ 󰌙 ]</span>";
        on-click = "hyprctl dispatch exec '[float; center; size 950 650] kitty --title float_kitty nmtui'";
      };

      tray = {
        icon-size = 14;
        spacing = 6;
      };

      pulseaudio = {
        format = "<span foreground='${blue}'>  </span>{volume}% <span foreground='${blue}'>]</span>";
        format-muted = "<span foreground='${blue}'>  </span>{volume}% <span foreground='${blue}'>]</span>";
        scroll-step = 2;
        on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        on-click-right = "hyprctl dispatch exec '[float; center; size 950 650] pavucontrol'";
      };

      "custom/mic" = {
        return-type = "json";
        interval = 1;
        tooltip = true;
        markup = true;
        signal = 5;
        exec = ''
          bash <<'BASH'
s=$(wpctl get-volume @DEFAULT_SOURCE@ 2>/dev/null || true)

if printf "%s" "$s" | grep -q MUTED; then
  icon=""; status="muted"
else
  icon=""; status="live"
fi

num=$(printf "%s" "$s" | grep -Eo '[0-9]+\.[0-9]+' | head -n1)
if [ -n "$num" ]; then
  vol=$(awk -v n="$num" 'BEGIN{printf("%d", n*100 + 0.5)}')
else
  vol="--"
fi

icon_markup="<span foreground='${blue}'>$icon</span>"
printf '{"text":"%s %s%%","tooltip":"Mic %s (%s)","class":"%s"}\n' \
  "$icon_markup" "$vol" "$status" "$vol%" "$status"
BASH
        '';
        format = "<span foreground='${blue}'>[ </span>{text} ";
        on-click = "wpctl set-mute @DEFAULT_SOURCE@ toggle; killall -RTMIN+5 waybar";
        on-click-right = "hyprctl dispatch exec '[float; center; size 950 650] pavucontrol'";
        on-scroll-up = "wpctl set-volume @DEFAULT_SOURCE@ 2%+ --limit 1.0; killall -RTMIN+5 waybar";
        on-scroll-down = "wpctl set-volume @DEFAULT_SOURCE@ 2%- --limit 1.0; killall -RTMIN+5 waybar";
        on-click-middle = "wpctl set-volume @DEFAULT_SOURCE@ 100% --limit 1.0; killall -RTMIN+5 waybar";
      };

      battery = {
        format =              "<span foreground='${yellow}'>[ 󰁹 </span>{capacity}% <span foreground='${yellow}'>]</span>";
        format-charging =     "<span foreground='${green}'>[ 󰂄 </span>{capacity}% <span foreground='${green}'>]</span>";
        format-full =         "<span foreground='${green}'>[ 󰂅 </span>{capacity}% <span foreground='${green}'>]</span>";
        format-warning =      "<span foreground='${red}'>[ 󰂎 </span>{capacity}% <span foreground='${red}'>]</span>";
        format-critical =     "<span foreground='${red}'>[ 󰂎! </span>{capacity}% <span foreground='${red}'>]</span>";
        interval = 5;
        states = {
          warning = 10;
          critical = 5;
        };
        format-time = "Time Left: {H}h{M}m";
        tooltip = true;
        tooltip-format = "{time}";
        on-click = "hyprctl dispatch exec '[float; center; size 950 650] cpupower-gui'";
      };

      "custom/cava" = {
        exec = "${waybarCava}/bin/WaybarCava";
        format = "<span foreground='${cyan}'>[</span> {} <span foreground='${cyan}'>]</span>";
        tooltip = false;
      };

      "custom/launcher" = {
        format = "[  ]";
        on-click = "sh -c 'rofi -show drun || pkill rofi'";
        tooltip = true;
        tooltip-format = "Run Rofi";
      };

      "custom/swaync" = {
        format = "<span foreground='${orange}'>[  </span>";
        on-click = "sh -c 'sleep 0.1; swaync-client -t -sw'";
        on-click-right = "swaync-client -C";
        tooltip = true;
        tooltip-format = "SwayNC";
      };

      "custom/lyrics" = {
        return-type = "json";
        format = "<span foreground='${green}'>󰐎  </span>{text}";
        format-alt = "<span foreground='${green}'>󰐎  </span>{text}";
        hide-empty-text = true;
        escape = true;
        tooltip = false;
        exec-if = "which waybar-lyric";
        exec = "waybar-lyric --quiet -m55";
        on-click = "waybar-lyric play-pause";
        on-click-right = "waybar-lyric next";
        on-click-middle = "waybar-lyric previous";
      };

      "custom/power" = {
        format = "<span foreground='${orange}'>  ]</span>";
        tooltip = true;
        tooltip-format = "Power menu";
        on-click = "wlogout -b 3 -n -P 0 -T 250 -B 250 -L 500 -R 500";
      };
    };
  };
}