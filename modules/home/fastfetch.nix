{ pkgs, ... }:
{
  programs.fastfetch = {
    enable = true;
    settings = {
      logo = {
        source = "nixos_small";
        padding = {
          right = 1;
        };
      };
      display = {
        size = {
          binaryPrefix = "si";
        };
        color = "red";
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
          format = "{14}:{17}:{20}";
        }
      ];
    };
  };
}
