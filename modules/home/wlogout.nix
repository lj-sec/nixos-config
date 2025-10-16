{ config, pkgs, ... }:
let
  p = config.colorScheme.palette;
in
{
  home.packages = with pkgs; [ wlogout ];

  wayland.windowManager.hyprland.settings.layerrule = [
    "blur, wlogout" "dimaround, wlogout" "ignorezero, wlogout"
  ];

  xdg.configFile."wlogout/layout".text = ''
    { "label": "lock",      "action": "hyprlock",                          "text": "󰌾" }
    { "label": "sleep",     "action": "systemctl sleep",                   "text": "󰒲" }
    { "label": "hibernate", "action": "systemctl hibernate",               "text": "󰤄" }
    { "label": "shutdown",  "action": "systemctl poweroff",                "text": "󰐥" }
    { "label": "reboot",    "action": "systemctl reboot",                  "text": "󰜉" }
    { "label": "bios",      "action": "systemctl reboot --firmware-setup", "text": "" }
  '';

  xdg.configFile."wlogout/style.css".text = ''
    * {
      font-family: "0xProto Nerd Font";
      color: #${p.base05};
    }

    window { background-color: transparent; }

    button {
      background-color: #${p.base00};
      border: 1px solid #${p.base03};
      border-radius: 18px;
      padding: 22px 26px;
      margin: 12px;
      min-width: 100px;
      min-height: 100px;
      background-image: none;
      box-shadow: 0 4px 16px rgba(0,0,0,.25); 
    }

    button:hover, button:focus {
      border-color: #${p.base05};
      box-shadow: 0 8px 22px rgba(0,0,0,.35);
    }

    button label {
      font-size: 6rem;
      margin: 0;
      padding: 0;
    }

    image { -gtk-icon-source: none; }

    label.keybind {
      font-size: 0;
      margin: 0;
      padding: 0;
      color: transparent;
    }

    #lock      { box-shadow: inset 0 -3px 0 0 #${p.base0D}; }
    #sleep     { box-shadow: inset 0 -3px 0 0 #${p.base0C}; }
    #hibernate { box-shadow: inset 0 -3px 0 0 #${p.base0B}; }
    #shutdown  { box-shadow: inset 0 -3px 0 0 #${p.base08}; }
    #reboot    { box-shadow: inset 0 -3px 0 0 #${p.base0A}; }
    #bios      { box-shadow: inset 0 -3px 0 0 #${p.base06}; }
  '';
}