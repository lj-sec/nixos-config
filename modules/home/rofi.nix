{ config, pkgs, ... }:
let
  p = config.colorScheme.palette;
in
{
  home.packages = with pkgs; [ rofi ];

  xdg.configFile."rofi/theme.rasi".text = ''
    * {
      bg-col:       #${p.base01};
      bg-col-light: #${p.base00};
      border-col:   #${p.base08};
      selected-col: #${p.base03};
      alt:          #${p.base09};
      fg-col:       #${p.base05};
      fg-col2:      #${p.base08};
      grey:         #${p.base03};
      highlight:    @alt;
    }
  '';

  xdg.configFile."rofi/config.rasi".text = ''
    configuration{
      modi: "run,drun,window";
      lines: 5;
      cycle: false;
      font: "0xProto Nerd Font 12";
      show-icons: true;
      icon-theme: "Papirus-dark";
      terminal: "kitty";
      drun-display-format: "{icon} {name}";
      location: 1;
      xoffset: 8;
      yoffset: 8;
      disable-history: true;
      hide-scrollbar: true;
      display-drun: " Apps ";
      display-run: " Run ";
      display-window: " Window ";
      /* display-Network: " Network"; */
      sidebar-mode: true;
      sorting-method: "fzf";
    }

    @theme "theme"

    element-text, element-icon , mode-switcher {
      background-color: inherit;
      text-color:       inherit;
    }

    window {
      height: 530px;
      width: 400px;
      border: 2px;
      border-color: @border-col;
      background-color: @bg-col;
    }

    mainbox {
      background-color: @bg-col;
    }

    inputbar {
      children: [prompt,entry];
      background-color: @bg-col-light;
      border-radius: 5px;
      padding: 0px;
    }

    prompt {
      background-color: @alt;
      padding: 4px;
      text-color: @bg-col-light;
      border-radius: 3px;
      margin: 10px 0px 10px 10px;
    }

    textbox-prompt-colon {
      expand: false;
      str: ":";
    }

    entry {
      padding: 6px;
      margin: 10px 10px 10px 5px;
      text-color: @fg-col;
      background-color: @bg-col;
      border-radius: 3px;
    }

    listview {
      border: 0px 0px 0px;
      padding: 6px 0px 0px;
      margin: 10px 0px 0px 6px;
      columns: 1;
      background-color: @bg-col;
      cycle: true;
    }

    element {
      padding: 8px;
      margin: 0px 10px 4px 4px;
      background-color: @bg-col;
      text-color: @fg-col;
    }

    element-icon {
      size: 28px;
    }

    element selected {
      background-color:  @selected-col ;
      text-color: @fg-col2  ;
      border-radius: 3px;
    }

    mode-switcher {
      spacing: 0;
    }

    button {
      padding: 10px;
      background-color: @bg-col-light;
      text-color: @grey;
      vertical-align: 0.5;
      horizontal-align: 0.5;
    }

    button selected {
      background-color: @bg-col;
      text-color: @alt;
    }
  '';
}