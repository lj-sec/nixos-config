{ config, ... }:
let
  p = config.colorScheme.palette; 
  custom = {
    font = "0xProto Nerd Font";
    font_size    = "15px";
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
      * {
        background: ${background_0};
        border: none;
        border-radius: 0px;
        padding: 0;
        margin: 0;
        font-family: "${font}";
        font-weight: ${font_weight};
        opacity: ${opacity};
        font-size: ${font_size};
      }
  
      window#waybar {
        background: ${background_1};
      }
  
      tooltip {
        background: ${background_0};
        border: 1px solid ${border_color};
      }
      tooltip label {
        margin: 5px;
        color: ${text_color};
      }
  
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

      #clock {
        color: ${text_color};
      }
  
      #tray {
        margin-left: 10px;
        color: ${text_color};
      }
      #tray menu {
        background: ${background_1};
        border: 1px solid ${border_color};
        padding: 8px;
      }
      #tray menuitem {
        padding: 1px;
      }
  
      #pulseaudio, #network, #cpu, #memory, #battery {
        padding-left: 5px;
        padding-right: 5px;
        margin-right: 10px;
        color: ${text_color};
      }
   
      #pulseaudio {
        margin-left: 15px;
      }

      #custom-launcher {
        font-size: ${font_size};
        color: ${text_color};
        font-weight: bold;
        margin-left: 15px;
        padding-right: 10px;
      }
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
        "tray"
      ];
      modules-center = [
        "clock"
      ];
      modules-right = [
        "cpu"
        "memory"
        "pulseaudio"
        "network"
        "battery"
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
      };
      "hyprland/workspaces" = {
        active-only = false;
        disable-scroll = true;
        format = "{icon}";
        on-click = "activate";
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
          sort-by-number = true;
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
        format = "<span foreground='${green}'> </span> {usage}%";
        format-alt = "<span foreground='${green}'> </span> {avg_frequency} GHz";
        interval = 2;
        on-click-right = "hyprctl dispatch exec '[float; center; size 950 650] kitty --override font_size=14 --title float_kitty btop'";
      };
      memory = {
        format = "<span foreground='${cyan}'> </span> {}%";
        format-alt = "<span foreground='${cyan}'> </span> {used} GiB";
        interval = 2;
        on-click-right = "hyprctl dispatch exec '[float; center; size 950 650] kitty --override font_size=14 --title float_kitty btop'";
      };
      network = {
        format-wifi = "<span foreground='${magenta}'> </span> {signalStrength}%";
        format-ethernet = "<span foreground='${magenta}'>󰈀 </span>";
        tooltip-format = "Connected to {essid} {ifname} via {gwaddr}";
        format-linked = " {ifname} (No IP)";
        format-disconnected = "<span foreground='${magenta}'>󰌙b </span>";
      };
      tray = {
        icon-size = 15;
        spacing = 10;
      };
      pulseaudio = {
        format = "  {volume}%";
        format-muted = "<span foreground='${blue}'> </span> {volume}%";
        scroll-step = 2;
        on-click = "pamixer -t";
        on-click-right = "pavucontrol";
      };
      battery = {
        format = "<span foreground='${yellow}'>󰁹 </span> {capacity}%";
        format-charging = "<span foreground='${yellow}'>󰂄 </span> {capacity}%";
        format-full = "<span foreground='${yellow}'>󰂅 </span> {capacity}%";
        format-warning = "<span foreground='${yellow}'> </span> {capacity}%";
        interval = 5;
        states = {
          warning = 25;
        };
        format-time = "{H}h{M}m";
        tooltip = true;
        tooltip-format = "{time}";
      };
      "custom/launcher" = {
        format = "";
        on-click = "rofi -show drun";
        tooltip = true;
        tooltip-format = "Run Rofi";
      };
    }; 
  };
}
