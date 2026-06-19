{ ... }:
{
  programs.rofi = {
    enable = true;
    cycle = false;
    font = "0xProto Nerd Font 12";
    location = "top-left";
    modes = [ "run" "drun" "window" ];
    terminal = "kitty";
    xoffset = 8;
    yoffset = 8;

    extraConfig = {
      "click-to-exit" = true;
      "disable-history" = true;
      "display-drun" = " Apps ";
      "display-run" = " Run ";
      "display-window" = " Window ";
      "drun-display-format" = "{icon} {name}";
      "hide-scrollbar" = true;
      "icon-theme" = "Papirus-dark";
      lines = 5;
      "show-icons" = true;
      "sidebar-mode" = true;
      "sorting-method" = "fzf";
    };
  };
}
