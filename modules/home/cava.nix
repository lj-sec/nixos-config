{ config, pkgs, username, ... }:
let
  cavaFeeder = pkgs.writeShellScript "cava-waybar-feeder.sh" ''
    #!/usr/bin/env bash
    tmpfile="''${XDG_RUNTIME_DIR}/cava-waybar.json"

    # run cava with our config so we get semicolon-separated ascii levels
    ${pkgs.cava}/bin/cava -p "${config.home.homeDirectory}/.config/cava/config" | while read -r line; do
      json="[$(echo "''${line}" | ${pkgs.coreutils}/bin/tr ';' ',' | ${pkgs.gnused}/bin/sed 's/,$//')]"
      echo "''${json}" > "''${tmpfile}"
      ${pkgs.procps}/bin/pkill -RTMIN+6 waybar 2>/dev/null || true
    done
  '';
in
{
  xdg.configFile."cava/config" = {
    force = true;
    text = ''
      [general]
      framerate = 30
      bars = 20

      [input]
      method = pipewire

      [output]
      method = raw
      channels = mono
      data_format = ascii

      [smoothing]
      gravity = 80
      integral = 50
      monstercat = 1
      waves = 0
    '';
  };

  systemd.user.services."cava-waybar" = {
    Unit = {
      Description = "Run cava and expose bar levels for Waybar";
      After = [ "pipewire.service" ];
    };

    Service = {
      Environment = [
        "XDG_RUNTIME_DIR=/run/user/"
      ];
      ExecStart = "${cavaFeeder}";
      Restart = "always";
      RestartSec = 1;
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  home.file.".config/waybar/scripts/cava-waybar.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash

      # Fallback if XDG_RUNTIME_DIR isn't set yet at first Waybar spawn
      if [ -z "''${XDG_RUNTIME_DIR:-}" ]; then
        UIDNUM="$(${pkgs.coreutils}/bin/id -u)"
        XDG_RUNTIME_DIR="/run/user/''${UIDNUM}"
      fi

      tmpfile="''${XDG_RUNTIME_DIR}/cava-waybar.json"

      if [ ! -f "''${tmpfile}" ]; then
        echo '{"text": "…", "class": "cava", "tooltip": "audio"}'
        exit 0
      fi

      raw="$(cat "''${tmpfile}" 2>/dev/null || true)"

      if [ -z "''${raw}" ]; then
        echo '{"text": "…", "class": "cava", "tooltip": "audio"}'
        exit 0
      fi

      blocks=(" " "▁" "▂" "▃" "▄" "▅" "▆" "▇" "█")

      bar=""

      vals=$(echo "''${raw}" | ${pkgs.coreutils}/bin/tr -d '[]' | ${pkgs.coreutils}/bin/tr ',' ' ')
      for v in ''${vals}; do
        lvl=$(( v * 8 / 1000 ))
        if [ "''${lvl}" -gt 8 ]; then
          lvl=8
        fi
        bar+="''${blocks[$lvl]}"
      done

      printf '{"text":"%s","class":"cava","tooltip":"audio levels"}\n' "''${bar}"
    '';
  };
}