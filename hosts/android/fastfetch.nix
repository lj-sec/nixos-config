{ ... }:

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
        color = "#89b4fa";
        separator = ": ";
      };
      modules = [
        { type = "title"; }
        { type = "os"; }
        { type = "kernel"; }
        {
          type = "disk";
          key = "Home";
          folders = [ "/data/data/com.termux.nix/files/home" ];
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
