{ config, inputs, pkgs, host, hasFingerprint, lib, ... }:
let
  p = config.colorScheme.palette;
  withA = hex: aa: "#${hex}${aa}";
  font = "0xProto Nerd Font";
  authCfg =
    if hasFingerprint then {
      "fingerprint:enabled" = true;
      "fingerprint:ready_message" = "Touch fingerprint sensor";
      "fingerprint:present_message" = "Scanning fingerprint...";
      "fingerprint:retry_delay" = 350;

      "pam:enabled" = true;
      "pam:module" = "hyprlock";
    } else {
      "pam:enabled" = true;
      "pam:module" = "hyprlock";
      "fingerprint:enabled" = false;
    };
  placeholder_text =
  if hasFingerprint
  then "<i>$FPRINTPROMPT</i>"
  else "<i>$PAMPROMPT</i>";
in
{
  programs.hyprlock = lib.mkForce {
    enable = true;
    package = inputs.hyprlock.packages.${pkgs.stdenv.hostPlatform.system}.hyprlock;

    settings = {
      general = {
        hide_cursor = true;

        # If you accidentally hit Enter, don't "fail" just because input is empty.
        ignore_empty_input = true;

        # Render widgets immediately; avoids weird “late” UI.
        immediate_render = true;

        # Keep your preference
        fractional_scaling = 0;

        # How long until the UI resets after a failed attempt (ms).
        fail_timeout = 1800;

        # Avoid trailing newlines from cmd[] labels
        text_trim = true;
      };
      
      auth = authCfg;

      background = [
        {
          monitor = "";
          path = "${../../../wallpapers/blackwave-cat.jpg}";
          blur_passes = 1;
          contrast = 0.90;
          brightness = 0.90;
          vibrancy = 0.20;
          vibrancy_darkness = 0.0;
        }
      ];

      label = [
        {
          monitor = "";
          text = " $TIME";
          color = "#${p.base05}";
          font_size = 115;
          font_family = font;
          shadow_passes = 3;
          position = "250, -50";
          halign = "center";
          valign = "center";
        }

        # Date
        {
          monitor = "";
          text = ''cmd[update:60000] echo "- $(date +'%A, %B %d') -" '';
          color = "#${p.base04}";
          font_size = 18;
          font_family = font;
          position = "250, -150";
          halign = "center";
          valign = "center";
        }

        # Username
        {
          monitor = "";
          text = "$USER";
          color = "#${p.base06}";
          font_size = 15;
          font_family = font;
          position = "0, 145";
          halign = "center";
          valign = "bottom";
        }
      ];

      input-field = [
        {
          monitor = "";
          size = "275, 40";
          outline_thickness = 1;
          rounding = 10;

          outer_color = withA p.base01 "33";
          inner_color = withA p.base01 "33";
          font_color = "#${p.base05}";
          fail_color = "#${p.base08}";

          font_size = 11;
          font_family = font;

          hide_input = false;
          fade_on_empty = false;

          # Live prompt text from fingerprint auth
          placeholder_text = placeholder_text;

          # On failure, show the reason and attempts
          fail_text = "<i>$FAIL</i> <b>($ATTEMPTS)</b>";

          position = "0, 100";
          halign = "center";
          valign = "bottom";
        }
      ];
    };
  };
}
