{ ... }:
{
  catppuccin.kitty.enable = true;

  programs.kitty = {
    enable = true;
    settings = {
      background_opacity = "1";
      dynamic_background_opacity = "yes";

      font_family = "0xProto Nerd Font Mono";
      font_size = 10;

      confirm_os_window_close = 0;
    };
    keybindings = {
      "ctrl+shift+c" = "copy_to_clipboard";
      "ctrl+shift+v" = "paste_from_clipboard";
      "ctrl+equal"       = "change_font_size all +0.5";
      "ctrl+minus"       = "change_font_size all -0.5";
    };
    extraConfig = ''
      mouse_map right  press paste_from_clipboard
      mouse_map middle press paste_from_selection
    '';
  };
}
