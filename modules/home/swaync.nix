{ config, pkgs, ... }:
let
  p = config.colorScheme.palette;
in
{
  services.swaync = {
    enable = true;

    settings = {
      positionX = "right";
      positionY = "top";
      layer = "overlay";
      "layer-shell" = true;

      cssPriority = "user";
      "notification-window-width" = 250;
      "control-center-width" = 320;
      "control-center-height" = 540;

      timeout = 5;
      "timeout-low" = 5;
      "timeout-critical" = 0;

      "image-visibility" = "when-available";
      "notification-icon-size" = 42;

      "keyboard-shortcuts" = true;
      "transition-time" = 180;
      "fit-to-screen" = true;

      widgets = [ "title" "dnd" "notifications" "volume" "backlight" ];

      "widget-config" = {
        title = {
          text = "Notifications";
          "clear-all-button" = true;
          "button-text" = "Clear All";
        };
        dnd = { text = "Do Not Disturb"; };
      };
    };

    style = ''
      /* ===== Tokens from nix-colors ===== */
      @define-color base     #${p.base01};
      @define-color mantle   #${p.base00};
      @define-color crust    #${p.base02};

      @define-color text     #${p.base05};
      @define-color subtext0 #${p.base04};
      @define-color subtext1 #${p.base06};

      @define-color surface0 #${p.base01};
      @define-color surface1 #${p.base02};
      @define-color surface2 #${p.base03};

      @define-color accent   #${p.base0B}; /* usually green-ish */
      @define-color border   #${p.base03};

      @define-color shadow rgba(0, 0, 0, 0.25);

      /* ===== Globals ===== */
      * {
        font-family: "0xProto Nerd Font"
        font-size: 11px;
        background-clip: border-box;
      }
      label { color: @text; }

      /* ===== Toasts ===== */
      .notification {
        background: @base;
        border: 1px solid @crust;
        border-radius: 8px;
        box-shadow: 0 10px 30px @shadow;
        padding: 0;
      }
      .notification-content {
        min-height: 56px;
        margin: 8px;
        padding: 0;
        border-radius: 6px;
      }
      .summary { color: @text; font-weight: 600; font-size: 11px; }
      .time    { color: @subtext0; font-size: 10px; margin-top: 2px; }
      .body    { color: @subtext1; font-size: 11px; line-height: 1.25; }
      .body-image { border-radius: 4px; }

      .low      .summary { color: @subtext1; }
      .normal   .summary { color: @text; }
      .critical .summary { color: #${p.base08}; } /* red */

      /* ===== Actions ===== */
      .notification-default-action,
      .notification-action {
        background: transparent;
        border: none;
        color: @text;
      }
      .notification-default-action { border-radius: 6px; }
      .notification button {
        background: transparent; border: none; margin: 0; padding: 0; border-radius: 6px;
      }
      .notification button:hover { background: @surface0; }
      .close-button { background: @crust; color: @surface2; border-radius: 6px; }

      /* ===== Control Center ===== */
      .control-center {
        background: @crust;
        border: 1px solid @border;
        border-radius: 10px;
        box-shadow: 0 10px 30px @shadow;
      }
      .control-center-list { background: @crust; border-radius: 0 0 10px 10px; }
      .notification-row {
        background: @base; border: 1px solid @crust; border-radius: 8px;
        margin: 6px; padding: 4px;
      }
      .notification-row:hover,
      .notification-row:focus { outline: 1px solid @surface2; }

      /* Title + "Clear All" */
      .widget-title {
        background: inherit; border-radius: 10px 10px 0 0; padding-bottom: 8px;
      }
      .widget-title > label { margin: 12px 10px; font-size: 12px; font-weight: 700; }
      .widget-title > button {
        margin-right: 10px; padding: 4px 8px; background: @mantle; color: @text;
        border-radius: 6px; font-weight: 700;
      }
      .widget-title > button:hover { background: @base; }

      /* ===== DND ===== */
      .widget-dnd { margin: 6px; font-size: 12px; }
      .widget-dnd > switch {
        border: 1px solid @accent; border-radius: 12px; background: @surface0;
        box-shadow: none; min-height: 18px; min-width: 36px;
      }
      .widget-dnd > switch:checked { background: @surface2; }
      .widget-dnd > switch slider {
        background: @accent; border-radius: 12px; min-width: 16px; min-height: 16px;
      }

      /* ===== Sliders (volume/backlight) ===== */
      scale { margin: 0 10px; padding: 0; }
      scale trough { background: @surface0; border-radius: 6px; min-height: 8px; }
      scale highlight { min-height: 8px; border-radius: 6px; background: @accent; }
      scale slider {
        min-width: 12px; min-height: 12px; background: @mantle;
        border: 1px solid @border; border-radius: 50%; margin: -6px; box-shadow: none;
      }

      /* ===== Misc ===== */
      .blank-window { background: transparent; }
      .right.overlay-indicator { all: unset; }
    '';
  };
}
