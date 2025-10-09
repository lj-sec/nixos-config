{ pkgs, ... }:
{
  home.sessionVariables = {
    # Make toolkits/apps prefer Wayland
    SDL_VIDEODRIVER = "wayland";
    XDG_SESSION_TYPE = "wayland";
    # XDG_CURRENT_DESKTOP = "hyprland";
    # XDG_SESSION_DESKTOP = "hyprland";

    # GTK theming
    GDK_SCALE = 1;
    GDK_DPI_SCALE = 0.8;

    # Qt theming/scaling
    # QT_QPA_PLATFORM = "wayland";
    # QT_AUTO_SCREEN_SCALE = 1;
    # QT_STYLE_OVERRIDE = "kavantum";
    # QT_QPA_PLATFORMTHEME = "qt5ct";
    # QT_WAYLAND_DISABLE_WINDOWDECORATION = 1; 
  };
}
