{ pkgs, config, username, ... }:
let
    micmuteWpEvent = pkgs.writeShellScriptBin "micmute-wp-event" ''
    #!${pkgs.bash}/bin/bash
    set -uo pipefail   # no `-e` so transient failures don't kill the service

    pactl_bin=${pkgs.pulseaudio}/bin/pactl
    sudo_bin=/run/wrappers/bin/sudo
    led_cmd="/run/current-system/sw/bin/micmute-led"

    wait_for_pulse() {
      # Wait up to ~6s for the pulse server from PipeWire to be ready
      for i in {1..30}; do
        if "''${pactl_bin}" info >/dev/null 2>&1; then
          return 0
        fi
        sleep 0.2
      done
      return 1
    }

    update_led() {
      # If there's no default source yet, just skip
      if "''${pactl_bin}" get-source-mute @DEFAULT_SOURCE@ >/dev/null 2>&1; then
        if "''${pactl_bin}" get-source-mute @DEFAULT_SOURCE@ 2>/dev/null | grep -q 'yes'; then
          "''${sudo_bin}" "''${led_cmd}" 1 || true
        else
          "''${sudo_bin}" "''${led_cmd}" 0 || true
        fi
      fi
    }

    # Wait for pulse, do an initial sync (both tolerant of failure)
    wait_for_pulse || true
    update_led || true

    # Subscribe to pulse events and update on relevant changes
    "''${pactl_bin}" subscribe | while read -r line; do
      case "''${line}" in
        *"Event 'change' on source"*) update_led ;;
        *"Event 'new' on source"*)    update_led ;;
        *"Event 'change' on server"*) update_led ;;
        *"Event 'new' on server"*)    update_led ;;
      esac
    done
  '';
in
{
  imports = [
    ./swap.nix
    ./hardware-configuration.nix
    ./../../modules/core
  ];

  boot.kernelModules = [ "thinkpad_acpi" ];

  # Workaround to write to micmute LED without sudo
  security.sudo.extraRules = [
    {
      users = [ username ]; 
      commands = [
        {
          command = "/run/current-system/sw/bin/micmute-led";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
  systemd.user.services."micmute-sync" = {
    description = "Sync ThinkPad micmute LED with mic mute (event-driven via pactl subscribe)";
    # Make sure PipeWire pulse server & WirePlumber are up first
    after = [ "pipewire-pulse.service" "wireplumber.service" ];
    wants = [ "pipewire-pulse.service" "wireplumber.service" ];
    wantedBy = [ "default.target" ];
    serviceConfig = {
      ExecStart = "${micmuteWpEvent}/bin/micmute-wp-event";
      Restart = "always";
      RestartSec = 1;
      # Useful to see script stderr in the journal
      StandardError = "journal";
    };
  };

  # Expose all Fn hotkeys
  boot.extraModprobeConfig = ''
    options thinkpad_acpi hotkey=enable,0xffff hotkey_report_mode=2
  '';

  environment.systemPackages = with pkgs; [
    (writeShellScriptBin "micmute-led" ''
      #!/usr/bin/env bash
      # Usage: micmute-led 0|1
      echo "$1" > /sys/class/leds/platform::micmute/brightness
    '')
    acpi
    brightnessctl
    cpupower-gui
    linuxPackages.cpupower
    powertop
  ];
}