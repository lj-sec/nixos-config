{ ... }:
{
  services.swaync = {
    enable = true;

    settings = {
      positionX = "right";
      positionY = "top";
      layer = "overlay";
      "layer-shell" = true;

      cssPriority = "user";
      notification-window-width = 360;
      "control-center-width" = 420;
      "control-center-height" = 640;      

      timeout = 10;
      "timeout-low" = 5;
      "timeout-critical" = 0;

      "image-visibility" = "when-avaliable";
      "notification-icon-size" = 56;

      "keyboard-shortcuts" = true;
      "transition-time" = 180;
      "fit-to-screen" = true;

      widgets = [ "title" "dnd" "notificatons" ];
      "widget-config" = {
        title = {
          text = "Notifications";
          "clear-all-button" = true;
          "button-text" = "Clear All";
        };
        dnd = {
          text = "Do Not Disturb";
        };
      };
    };

    style = ./style.css;
  };
}
