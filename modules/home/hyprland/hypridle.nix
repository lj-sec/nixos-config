{ ... }:
{
  services.hypridle = {
    enable  = true;
    
    settings = {
      general = {
        after_sleep_cmd = "hyprctl dispatch dpms on";
        ignore_dbus_inhibbit = false;
        lock_cmd = "hyprlock";
      };

      listener = [
        {
          timeout = 280;
          on-timeout = "hyprshade on dim20";
          on-resume = "hyprshade off";
        }
        {
          timeout = 290;
          on-timeout = "hyprshade on dim40";
          on-resume = "hyprshade off";
        }
        {
          timeout = 300;
          on-timeout = "hyprlock";
        }
        {
          timeout = 880;
          on-timeout = "hyprshade on dim20";
          on-resume = "hyprshade off";
        }
        {
          timeout = 890;
          on-timeout = "hyprshade on dim40";
          on-resume = "hyprshade off";
        }
        {
          timeout = 900;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
      ];
    };

  };
}