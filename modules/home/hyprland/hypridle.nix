{ ... }:
{
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        after_sleep_cmd = "hyprctl dispatch dpms on";
        before_sleep_cmd = "hyprlock";
        ignore_dbus_inhibit = false;
        lock_cmd = "hyprlock";
      };

      listener = [
        # 4m20s: light dim
        {
          timeout = 260;
          on-timeout = "hyprshade on dim20";
          on-resume  = "hyprshade off";
        }
        # 4m40s: deeper dim
        {
          timeout = 280;
          on-timeout = "hyprshade on dim40";
          on-resume  = "hyprshade off";
        }
        # 5m: lock; keep the dim on until later
        {
          timeout = 300;
          on-timeout = "hyprlock";
        }
        # 10m50s: re-dim in case it woke briefly
        {
          timeout = 650;
          on-timeout = "hyprshade on dim20";
          on-resume  = "hyprshade off";
        }
        # 11m15s: deeper dim again
        {
          timeout = 675;
          on-timeout = "hyprshade on dim40";
          on-resume  = "hyprshade off";
        }
        # 11m40s: turn displays off
        {
          timeout = 700;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume  = "hyprctl dispatch dpms on; hyprshade off";
        }
        # 12m5s: go to sleep (then hibernate via systemd)
        {
          timeout = 725;
          on-timeout = "systemctl suspend-then-hibernate";
        }
      ];
    };
  };
}
