{ pkgs, config, ... }:
let
  p = config.colorScheme.palette;
in
{
  programs.fastfetch = {
    enable = true;
    settings = {
      logo = {
        type = "small";
        source = "";
        padding = {
          right = 1;
        };
      };
      display = {
        size = {
          binaryPrefix = "si";
        };
        color = "#${p.base0D}";
        separator = ": ";
      };
      modules = [
        { type = "title"; }
        { type = "os"; }
        { type = "kernel"; }
        { type = "wm"; }
        { 
          type = "disk";
          key = "Disk";
          folders =  [ "/" ];
          showUsed = true;
          showTotal = true;
        }
        {
          type = "battery";
          key = "Battery";
        }
        {
          type = "datetime";
          key = "Time";
          format = "{hour-pretty}:{minute-pretty}:{second-pretty}";
        }
      ];
    };
  };
}
