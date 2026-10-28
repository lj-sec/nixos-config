{ config, lib, ... }:
let
  p = config.colorScheme.palette;
  # SwayNC's packaged CSS uses comma-separated RGB channels for notification backgrounds.
  rgb = hex: lib.concatMapStringsSep ", "
    (offset: toString (lib.fromHexString (builtins.substring offset 2 hex)))
    [ 0 2 4 ];
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

      "notification-window-width" = 390;
      "control-center-width" = 410;
      "control-center-height" = 690;
      "control-center-margin-top" = 8;
      "control-center-margin-right" = 8;
      "control-center-margin-bottom" = 8;
      "fit-to-screen" = false;

      timeout = 5;
      "timeout-low" = 5;
      "timeout-critical" = 0;
      "image-visibility" = "when-available";
      "notification-icon-size" = 40;
      "keyboard-shortcuts" = true;
      "transition-time" = 180;

      # Keep controls together and let only the notification history scroll.
      widgets = [ "title" "dnd" "mpris" "volume" "backlight" "notifications" ];
      "widget-config" = {
        title = {
          text = "Notifications";
          "clear-all-button" = true;
          "button-text" = "Clear All";
        };
        dnd.text = "Do Not Disturb";
        mpris = {
          autohide = true;
          "show-album-art" = "when-available";
        };
        # GTK centers these labels; equal text widths align the icons as well as the tracks.
        volume.label = "󰕾 Volume   ";
        backlight = {
          label = " Backlight";
          device = "amdgpu_bl1";
          subsystem = "backlight";
        };
        notifications.vexpand = true;
      };
    };

    # Override the Catppuccin module's stylesheet, while keeping the shared palette.
    # Use GTK CSS and the packaged widget structure; browser layout properties and
    # blanket overrides on notification-group descendants break GTK's allocations.
    style = lib.mkForce ''
      @define-color panel   #${p.base00};
      @define-color card    #${p.base01};
      @define-color surface #${p.base02};
      @define-color border  #${p.base03};
      @define-color muted   #${p.base04};
      @define-color text    #${p.base05};
      @define-color accent  #${p.base0B};
      @define-color danger  #${p.base08};

      :root {
        --cc-bg: @panel;
        --noti-bg: ${rgb p.base01};
        --noti-bg-alpha: 1;
        --noti-bg-darker: @panel;
        --noti-bg-hover: @surface;
        --noti-bg-focus: @surface;
        --noti-border-color: @border;
        --noti-close-bg: @surface;
        --noti-close-bg-hover: @border;
        --text-color: @text;
        --text-color-disabled: @muted;
        --bg-selected: @accent;
        --border: 1px solid @border;
        --border-radius: 6px;
        --notification-shadow: none;
        --font-size-body: 13px;
        --font-size-summary: 14px;
        --notification-icon-size: 40px;
        --notification-group-icon-size: 20px;
        --mpris-album-art-icon-size: 56px;
        --mpris-album-art-overlay: @card;
        --mpris-album-art-shadow: none;
      }

      * {
        font-family: "0xProto Nerd Font";
        font-size: 13px;
        text-shadow: none;
      }

      label { color: @text; }

      /* One card owns the border, urgency stripe, content and action buttons. */
      .notification-row,
      .notification-row:focus {
        background: transparent;
        padding: 0;
        margin: 0;
        outline: none;
      }

      .notification-row .notification-background { padding: 5px 14px; }

      .notification-row .notification-background .notification {
        margin: 0;
        padding: 0;
        background: @card;
        border: 1px solid @border;
        border-left: 3px solid @accent;
        border-radius: 6px;
        box-shadow: none;
      }

      .notification-row .notification-background .notification.low { border-left-color: @muted; }
      .notification-row .notification-background .notification.critical { border-left-color: @danger; }

      .notification-default-action {
        margin: 0;
        padding: 10px;
        border: none;
        border-radius: 4px;
        background: transparent;
        box-shadow: none;
      }

      .notification-default-action:hover,
      .notification-default-action:focus { background: @surface; }
      .notification-content { margin: 0; padding: 0; background: transparent; }
      .summary { font-weight: 700; }
      .time { color: @muted; font-size: 11px; }
      .body { color: @text; }
      .image, .body-image { border-radius: 4px; }

      .notification-alt-actions {
        margin: 0;
        padding: 0 6px 6px;
        background: transparent;
      }
      .notification-action { margin: 0 3px; padding: 0; }
      .notification-action > button,
      .inline-reply-button {
        padding: 6px 10px;
        background: @surface;
        color: @text;
        border: 1px solid @border;
        border-radius: 4px;
        box-shadow: none;
      }
      .notification-action > button:hover { background: @border; }

      .close-button {
        min-width: 20px;
        min-height: 20px;
        margin: 10px 18px 0 0;
        padding: 0;
        background: @surface;
        color: @text;
        border: 1px solid @border;
        border-radius: 4px;
        box-shadow: none;
      }
      .close-button:hover { background: @danger; color: @panel; }

      .control-center {
        background: @panel;
        border: 1px solid @border;
        border-radius: 8px;
        box-shadow: none;
      }
      .control-center-list { padding: 0; background: transparent; }
      .control-center-list-placeholder { color: @muted; }
      .widget { margin: 0; padding: 0; }

      /* Both header rows share left and right edges, including their controls. */
      .widget-title,
      .widget-dnd {
        margin: 0 14px;
        padding: 10px 0;
        min-height: 28px;
      }
      .widget-title { border-bottom: 1px solid @surface; }
      .widget-title > label,
      .widget-dnd > label { margin: 0; padding: 0; }
      .widget-title > label { font-size: 15px; font-weight: 700; }
      .widget-dnd > label { font-size: 13px; }
      .widget-title > button {
        margin: 0;
        padding: 5px 10px;
        min-height: 18px;
        color: @text;
        background: @card;
        border: 1px solid @border;
        border-radius: 4px;
        box-shadow: none;
      }
      .widget-title > button:hover { background: @surface; }
      .widget-title > button:disabled { color: @muted; }

      .widget-dnd switch {
        margin: 0;
        padding: 2px;
        min-width: 38px;
        min-height: 18px;
        background: @surface;
        border: 1px solid @border;
        border-radius: 4px;
        box-shadow: none;
      }
      .widget-dnd switch:checked { background: alpha(@accent, 0.2); border-color: @accent; }
      .widget-dnd switch slider {
        min-width: 14px;
        min-height: 14px;
        background: @muted;
        border: none;
        border-radius: 2px;
        box-shadow: none;
      }
      .widget-dnd switch:checked slider { background: @accent; }

      /* Volume nests its row in a box; backlight puts it directly in the widget. */
      .widget-volume,
      .widget-backlight { margin: 0 14px; padding: 3px 0; }
      .widget-backlight { padding-bottom: 12px; border-bottom: 1px solid @surface; }
      .widget-volume > box > label,
      .widget-backlight > label { min-width: 100px; margin: 0; padding: 0; }

      scale { margin: 0; padding: 8px 6px; }
      scale trough {
        min-height: 6px;
        background: @surface;
        border: none;
        border-radius: 2px;
        box-shadow: none;
      }
      scale highlight {
        min-height: 6px;
        background: @accent;
        border: none;
        border-radius: 2px;
      }
      scale slider {
        min-width: 10px;
        min-height: 14px;
        margin: -4px 0;
        background: @text;
        border: none;
        border-radius: 2px;
        box-shadow: none;
      }
      scale slider:hover { background: @accent; }

      progressbar { margin-top: 6px; }
      progressbar trough,
      progressbar progress { min-height: 6px; border: none; border-radius: 2px; }
      progressbar trough { background: @surface; }
      progressbar progress { background: @accent; }

      /* Preserve SwayNC's stack layout and gestures; only style group headers. */
      .notification-group,
      .notification-group:hover,
      .notification-group:focus {
        margin: 6px 0;
        padding: 0;
        background: transparent;
        outline: none;
      }
      .notification-group.collapsed.not-expanded { opacity: 1; }
      .notification-group .notification-group-headers,
      .notification-group .notification-group-buttons { margin: 4px 14px; }
      .notification-group-header { font-size: 13px; font-weight: 700; }
      .notification-group .notification-group-close-button .close-button { margin: 8px 14px; }

      /* Media controls appear only when an MPRIS player supplies metadata. */
      .widget-mpris { margin: 0 14px 8px; padding: 0; }
      .widget-mpris .widget-mpris-player {
        margin: 0;
        background: @card;
        border: 1px solid @border;
        border-radius: 6px;
        box-shadow: none;
      }
      .widget-mpris .mpris-background { opacity: 0; }
      .widget-mpris .mpris-overlay { padding: 10px; background: @card; }
      .widget-mpris .widget-mpris-album-art { border-radius: 4px; box-shadow: none; }
      .widget-mpris .widget-mpris-title { font-size: 14px; font-weight: 700; }
      .widget-mpris .widget-mpris-subtitle { font-size: 12px; color: @muted; }
      .widget-mpris button {
        min-width: 24px;
        min-height: 24px;
        margin: 0;
        padding: 4px;
        color: @text;
        background: transparent;
        border: none;
        border-radius: 4px;
        box-shadow: none;
      }
      .widget-mpris button:hover { background: @surface; }
      .widget-mpris button:disabled { color: @muted; }
      .blank-window, .floating-notifications { background: transparent; }
    '';
  };
}
