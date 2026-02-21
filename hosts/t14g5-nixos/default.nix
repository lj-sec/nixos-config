{ pkgs, config, username, ... }:
let
  micmuteToggle = pkgs.writeShellScript "micmute-toggle" ''
    set -euo pipefail

    USER_NAME="${username}"
    LED="/sys/class/leds/platform::micmute/brightness"
    USER_ID="$(${pkgs.coreutils}/bin/id -u "$USER_NAME")"

    as_user() {
      ${pkgs.util-linux}/bin/runuser -u "$USER_NAME" -- ${pkgs.coreutils}/bin/env \
        XDG_RUNTIME_DIR="/run/user/$USER_ID" \
        DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$USER_ID/bus" \
        "$@"
    }

    # Toggle mic mute
    as_user ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle

    # Sync LED to actual mute state
    if as_user ${pkgs.wireplumber}/bin/wpctl get-volume @DEFAULT_AUDIO_SOURCE@ \
      | ${pkgs.gnugrep}/bin/grep -q '\[MUTED\]'; then
      echo 1 > "$LED"
    else
      echo 0 > "$LED"
    fi

    ${pkgs.procps}/bin/pkill -RTMIN+5 waybar || true
  '';
in
{
  imports = [
    ./swap.nix
    ./hardware-configuration.nix
    ./../../modules/core
  ];

  services.acpid = {
    enable = true;
    logEvents = true;

    handlers.micmute = {
      event = "button/micmute.*";
      action = "${micmuteToggle} && tee";
    };
  };

  # Rebinding Copilot key
  services.keyd = {
    enable = true;
    keyboards = {
      default = {
        ## the id of your keyboard taken from the monitor command - specifying it here and not using a wildcard * might avoid the aforementioned libinput issue with palm rejection.  
        ids = [ "0001:0001:09b4e68d" ];
        settings = {
          main = {
            ## taking the key combination from the monitor command and remapping it to meta / super key
            "leftshift+leftmeta+f23" = "layer(meta)";
          };
        };
      };
    };
  };

  users.groups.micled = {};
  users.users.${username}.extraGroups = [ "micled" ];

  systemd.tmpfiles.rules = [
    "z /sys/class/leds/platform::micmute/brightness 0664 root micled - -"
  ];

  environment.systemPackages = with pkgs; [
    acpi
    brightnessctl
    cpupower-gui
    linuxPackages.cpupower
    powertop
  ];
}