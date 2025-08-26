{ ... }:
{
  services.swaync = {
    enable = true;
    settings = {
      workspace = 10;
      output = "eDP-1";
    };
  };
}
