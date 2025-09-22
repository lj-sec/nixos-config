{ pkgs, ... }:
{
  systemd.user.services.polkit-agent = {
    Unit = {
      Description = "polkit authentication agent";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Type = "simple";
      Restart = "on-failure";
      Environment = "XDG_CURRENT_DESKTOP=Hyprland";
    };
    Install = { WantedBy = [ "graphical-session.target" ]; };
  };
}