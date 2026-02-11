{ config, pkgs, lib, ... }:
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

      "notification-window-width" = 300;
      "control-center-width" = 340;
      "control-center-height" = 460;

      timeout = 5;
      "timeout-low" = 5;
      "timeout-critical" = 0;

      "image-visibility" = "when-available";
      "notification-icon-size" = 40;

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
        volume = { label = "󰕾 Volume"; };
        backlight = {
          label = " Backlight";
          device = "amdgpu_bl1";
          subsystem = "backlight";
        };
      };
    };

    style = lib.mkForce ''
      /* ===== nix-colors tokens ===== */
      @define-color base     #${p.base01};
      @define-color mantle   #${p.base00};
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

      /* ===== Globals ===== */
      * {
        font-family: "0xProto Nerd Font";
        font-size: 11px;
        background-clip: border-box;
        min-height: 0;
        letter-spacing: 0.1px;
      }
      label { color: @text; }

      /* ===== Toasts (popups) ===== */
      /* Outer container stripped — no double background */
      .notification {
        background: transparent !important;
        border: none !important;
        padding: 0 !important;
        margin: 6px 8px !important;
        box-shadow: none !important;
      }

      .notification-content { margin: 0 !important; padding: 0 !important; }

      /* Main clickable card */
      .notification-default-action {
        display: block;
        width: 100%;
        margin: 0;
        padding: 8px 10px;
        background: @mantle;
        border: 1px solid @surface2;
        border-radius: 10px;
        box-shadow: 0 10px 30px @shadow;
        transition: background .12s ease, transform .06s ease, box-shadow .12s ease;
      }

      /* Left accent stripe per urgency */
      .notification.low      .notification-default-action { box-shadow: inset 3px 0 0 0 @subtext1, 0 10px 30px @shadow; }
      .notification.normal   .notification-default-action { box-shadow: inset 3px 0 0 0 @accent,   0 10px 30px @shadow; }
      .notification.critical .notification-default-action { box-shadow: inset 3px 0 0 0 @danger,   0 10px 30px @shadow; }

      /* Hover + active states */
      .notification-default-action:hover {
        background: @base;
        transform: translateY(-1px);
        box-shadow: 0 0 8px alpha(@accent, 0.15), inset 3px 0 0 0 @accent;
      }
      .notification-default-action:active {
        transform: translateY(0);
        background: @surface0;
        box-shadow: 0 0 6px alpha(@accent, 0.12), inset 3px 0 0 0 @accent;
      }

      .summary { color: @text; font-weight: 700; font-size: 12px; }
      .time    { color: @subtext0; font-size: 10px; margin-top: 1px; }
      .body {
        color: @subtext1;
        font-size: 11px;
        line-height: 1.25;
        max-height: calc(1.25em * 2);
        overflow: hidden;
      }
      .notification:hover .body { overflow: visible; max-height: none; }

      .image, .app-icon, .body-image {
        border-radius: 8px;
        outline: 1px solid @surface2;
      }

      /* Secondary actions (below main card) */
      .notification-actions { margin-top: 6px; }
      .notification-action {
        padding: 4px 8px;
        background: @mantle;
        border: 1px solid @surface2;
        border-radius: 8px;
        cursor: pointer;
      }
      .notification-action:hover  { background: @base; }
      .notification-action:active { background: @surface0; }

      .close-button { background: @crust; color: @surface2; border-radius: 6px; }

      /* ===== Control Center ===== */
      .control-center {
        background: @base;
        border: 1px solid @border;
        border-radius: 12px;
        box-shadow: 0 10px 30px @shadow;
      }
      .control-center-list { background: transparent; padding: 8px; }

      /* Notification rows in CC */
      .notification-row {
        background: @mantle;
        border: 1px solid @surface2;
        border-radius: 10px;
        margin: 6px 4px;
        padding: 6px 8px;
        transition: background .12s ease, border-color .12s ease, transform .06s ease, box-shadow .12s ease;
        outline: none;
      }
      .notification-row.low      { box-shadow: inset 3px 0 0 0 @subtext1; }
      .notification-row.normal   { box-shadow: inset 3px 0 0 0 @accent; }
      .notification-row.critical { box-shadow: inset 3px 0 0 0 @danger; }

      /* === Lift effect on hover/focus (middle ground) === */
      .notification-row:hover,
      .notification-row:focus {
        background: @mantle;
        border-color: alpha(@accent, 0.35);
        box-shadow: 0 0 8px alpha(@accent, 0.15), inset 3px 0 0 0 @accent;
        transform: translateY(-1px);
        outline: none;
      }
      .notification-row:active {
        transform: translateY(0);
        box-shadow: 0 0 6px alpha(@accent, 0.12), inset 3px 0 0 0 @accent;
      }

      /* ===== Title + Clear All ===== */
      .widget-title {
        padding: 8px;
        border-bottom: 1px solid @surface2;
        border-radius: 12px 12px 0 0;
      }
      .widget-title > label { margin: 4px 8px; font-size: 13px; font-weight: 800; }
      .widget-title > button {
        margin-right: 8px;
        padding: 5px 10px;
        background: @mantle;
        color: @text;
        border: 1px solid @surface2;
        border-radius: 8px;
        font-weight: 700;
        cursor: pointer;
      }
      .widget-title > button:hover { background: @base; }

      /* ===== DND switch ===== */
      .widget-dnd { margin: 6px 8px; font-size: 12px; }
      .widget-dnd > switch {
        border: 1px solid @surface2;
        background: @surface0;
        min-height: 18px;
        min-width: 36px;
        border-radius: 14px;
        box-shadow: none;
      }
      .widget-dnd > switch:checked {
        background: alpha(@accent, 0.25);
        border-color: @accent;
      }
      .widget-dnd > switch slider {
        background: @accent;
        border-radius: 12px;
        min-width: 14px;
        min-height: 14px;
      }

      /* ===== Sliders ===== */
      scale { margin: 0 8px; padding: 0; }
      scale trough { background: @surface1; border-radius: 6px; min-height: 6px; }
      scale highlight { min-height: 6px; border-radius: 6px; background: @accent; }
      scale slider {
        min-width: 10px;
        min-height: 10px;
        background: @mantle;
        border: 1px solid @border;
        border-radius: 50%;
        margin: -5px;
        box-shadow: none;
      }

      /* ===== Group header font ===== */
      .notification-group-header,
      .notification-group-header label,
      .notification-group-header .summary,
      .notification-group-header .app-name {
        font-size: 11px !important;
        font-weight: 600 !important;
        color: @text;
        background: transparent;
        margin: 0;
        padding: 2px 4px;
      }

      .notification-group { margin-bottom: 4px; padding-bottom: 2px; }
      .notification-group,
      .notification-group * {
        padding-left: 0 !important;
        margin-left: 0 !important;
      }
      .notification-group .notification-row {
        margin: 6px 4px !important;
        padding-left: 8px;
      }
      .notification-group-header {
        margin: 6px 4px 0 4px !important;
        padding: 6px 8px !important;
      }

      /* ===== Misc ===== */
      .blank-window { background: transparent; }
      .right.overlay-indicator { all: unset; }
      button, .notification-row, .close-button { cursor: pointer; }

      /* ---- Control Center ---- */
      .control-center .notification-row,
      .control-center .notification-row.low,
      .control-center .notification-row.normal,
      .control-center .notification-row.critical {
        background: transparent !important;
        border: none !important;
        padding: 0 !important;
        margin: 8px 6px !important;
        box-shadow: none !important;
      }
      
      /* Urgency stripe */
      .control-center .notification.low      .notification-default-action { box-shadow: inset 3px 0 0 0 @subtext1, 0 10px 30px @shadow; }
      .control-center .notification.normal   .notification-default-action { box-shadow: inset 3px 0 0 0 @accent,   0 10px 30px @shadow; }
      .control-center .notification.critical .notification-default-action { box-shadow: inset 3px 0 0 0 @danger,   0 10px 30px @shadow; }
      .control-center .notification-default-action {
        display: block;
        width: 100%;
        margin: 0;
        padding: 10px 12px;
        background: @mantle;
        border: 1px solid @surface2;
        border-radius: 10px;
        box-shadow: 0 10px 30px @shadow;
        transition: background .12s ease, transform .06s ease, box-shadow .12s ease;
      }

      .control-center .notification-default-action:hover {
        background: @base;
        transform: translateY(-1px);
        box-shadow: 0 0 8px alpha(@accent, 0.15), inset 3px 0 0 0 @accent;
      }
      .control-center .notification-default-action:active {
        transform: translateY(0);
        background: @surface0;
        box-shadow: 0 0 6px alpha(@accent, 0.12), inset 3px 0 0 0 @accent;
      }
      .control-center .notification-actions { margin-top: 6px; }
      .control-center .notification-action {
        padding: 4px 8px;
        background: @mantle;
        border: 1px solid @surface2;
        border-radius: 8px;
        cursor: pointer;
      }
    '';
  };
}