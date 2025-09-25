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

      "control-center-layer" = "top";

      cssPriority = "user";

      "notification-window-width" = 260;
      "control-center-width" = 300;
      "control-center-height" = 520;

      timeout = 5;
      "timeout-low" = 5;
      "timeout-critical" = 0;

      "image-visibility" = "when-available";
      "notification-icon-size" = 36;

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
        volume = {
          label = "󰕾 Volume";
        };
        backlight = {
          label = " Backlight";
          device = "amdgpu_bl1";
          subsystem = "backlight";
        };
      };
    };

    style = ''
      /* ===== nix-colors tokens ===== */
      @define-color base     #${p.base00};
      @define-color mantle   #${p.base01};
      @define-color crust    #${p.base02};

      @define-color text     #${p.base05};
      @define-color subtext0 #${p.base04};
      @define-color subtext1 #${p.base06};

      @define-color surface0 #${p.base01};
      @define-color surface1 #${p.base02};
      @define-color surface2 #${p.base03};

      @define-color accent   #${p.base0B};
      @define-color border   #${p.base03};
      @define-color danger   #${p.base08};
      @define-color shadow rgba(0, 0, 0, 0.25);

      /* ===== Globals (compact) ===== */
      * {
        font-family: "0xProto Nerd Font";
        font-size: 11px;
        background-clip: border-box;
        min-height: 0;
      }
      label { color: @text; }

      /* ===== Toasts (popups) — compact w/ left stripe by urgency ===== */
      /* OUTER TOAST: owns border, radius, stripe, shadow */
      .notification {
        background: @base;
        border: 1px solid @crust;
        border-radius: 10px;
        background-clip: padding-box;   /* keep bg inside the border */
        padding: 6px 8px;               /* spacing lives here */
        margin: 4px 6px;                /* small gap from screen edges */

        /* left stripe by urgency, full height & follows radius */
        box-shadow: 0 10px 30px @shadow;  /* keep the drop shadow */
      }
      .notification.low      { box-shadow: inset 3px 0 0 0 @subtext1, 0 10px 30px @shadow; }
      .notification.normal   { box-shadow: inset 3px 0 0 0 @accent,   0 10px 30px @shadow; }
      .notification.critical { box-shadow: inset 3px 0 0 0 @danger,   0 10px 30px @shadow; }

      /* INNER CONTENT: no margin, no extra radius so the stripe touches top/bottom */
      .notification-content {
        margin: 0;              /* <-- was 6–8px; remove the gutter */
        padding: 0;             /* keep compact; add if you want more air */
        border-radius: 0;       /* let the outer container’s radius define the shape */
      }

      /* Make buttons hug the edges too */
      .notification button { margin: 0; }

      .summary { color: @text; font-weight: 600; font-size: 11px; }
      .time    { color: @subtext0; font-size: 10px; margin-top: 1px; }
      .body    { color: @subtext1; font-size: 11px; line-height: 1.25; }
      .body-image { border-radius: 4px; }

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

      /* ===== Control Center shell ===== */
      .control-center {
        background: @crust;
        border: 1px solid @border;
        border-radius: 10px;
        box-shadow: 0 10px 30px @shadow;
      }
      .control-center-list { background: @crust; border-radius: 0 0 10px 10px; padding: 6px; }

      .notification-row {
        background: @base;
        border: 1px solid @crust;
        border-radius: 10px;
        margin: 4px 2px;
        padding: 4px 6px;
      }
      .notification-row.low      { box-shadow: inset 3px 0 0 0 @subtext1; }
      .notification-row.normal   { box-shadow: inset 3px 0 0 0 @accent;   }
      .notification-row.critical { box-shadow: inset 3px 0 0 0 @danger;   }

      .notification-row:hover,
      .notification-row:focus { outline: 1px solid @surface2; background: @mantle; }

      /* ===== Title + Clear All ===== */
      .widget-title {
        background: inherit; border-radius: 10px 10px 0 0; padding: 6px 6px 8px 6px;
      }
      .widget-title > label { margin: 6px 8px; font-size: 12px; font-weight: 700; }
      .widget-title > button {
        margin-right: 8px; padding: 3px 7px; background: @mantle; color: @text;
        border-radius: 6px; font-weight: 700;
      }
      .widget-title > button:hover { background: @base; }

      /* ===== DND switch (compact) ===== */
      .widget-dnd { margin: 4px 6px; font-size: 12px; }
      .widget-dnd > switch {
        border: 1px solid @accent; border-radius: 12px; background: @surface0;
        box-shadow: none; min-height: 16px; min-width: 32px;
      }
      .widget-dnd > switch:checked { background: @surface2; }
      .widget-dnd > switch slider {
        background: @accent; border-radius: 12px; min-width: 14px; min-height: 14px;
      }

      /* ===== Sliders (volume/backlight) compact ===== */
      scale { margin: 0 8px; padding: 0; }
      scale trough { background: @surface0; border-radius: 6px; min-height: 6px; }
      scale highlight { min-height: 6px; border-radius: 6px; background: @accent; }
      scale slider {
        min-width: 10px; min-height: 10px; background: @mantle;
        border: 1px solid @border; border-radius: 50%; margin: -5px; box-shadow: none;
      }

      /* ===== Misc ===== */
      .blank-window { background: transparent; }
      .right.overlay-indicator { all: unset; }
    '';
  };
}
