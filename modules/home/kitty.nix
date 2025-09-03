{ ... }:
{
  programs.kitty = {
    enable = true;
    settings = {
      background_opacity = "0.75";
      dynamic_background_opacity = "yes";

      font_size = 9.0;

      confirm_os_window_close = 0;
    };
  };
}
