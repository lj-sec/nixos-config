{ pkgs, host, config, ... }:
let
  p = config.colorScheme.palette;
  red     = "#${p.base08}";
  orange  = "#${p.base09}";
  yellow  = "#${p.base0A}";
  green   = "#${p.base0B}";
  cyan    = "#${p.base0C}";
  blue    = "#${p.base0D}";
  magenta = "#${p.base0E}";
  brown   = "#${p.base0F}";
  white   = "#${p.base05}";
in
{
  # Workaround to not break emergency shell
  programs.bash = {
    enable = true;
    initExtra = ''
      if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
      then
        shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
        exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
      fi
    '';

    profileExtra = ''
      case $- in
        *i*)
          if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" ]];
          then
            exec ${pkgs.fish}/bin/fish --login
          fi
        ;;
      esac
    ''; 
  };
  programs.fish = {
    enable = true;
    
    shellAliases = {
      l  = "ls -alh";
      ll = "ls -l";
      gs = "git status";
      gpssl = "sudo gpclient --fix-openssl connect";
    };

    functions = {
      fish_greeting.body = ''
        if command -q fastfetch
          status --is-interactive; and test -t 1
          fastfetch
        end
      '';

      promisc = {
        description = "promisc <INTERFACE>";
        body = ''
          if test (count $argv) -ne 1
            echo "Usage: promisc <INTERFACE>" >&2
            exit 1
          end

          set -l iface $argv[1]

          # Optional sanity check
          if not ip link show dev $iface >/dev/null 2>&1
            echo "Interface not found: $iface" >&2
            exit 1
          end

          if ip -o link show dev $iface | string match -q '*PROMISC*'
            sudo ip link set dev $iface promisc off
            echo "$iface: promisc off"
          else
            sudo ip link set dev $iface promisc on
            echo "$iface: promisc on"
          end
        '';
      };

      passcp = {
        description = "passcp [ACCOUNT]";
        body = ''
          if test (command -v pass) != null
            set -l account ""
            if test (count $argv) -eq 1
              pass show $argv[1] | wl-copy
            else 
              echo "Usage: passcp [ACCOUNT]"
            end
          else
            echo "Command 'pass' not found; exiting"
          end
        '';
      };

      rebuild = {
        description = "nixos-rebuild [ACTION] [FLAKE] [HOST]";
        body = ''
          set -l action switch
          set -l flake .
          set -l host '${host}'

          if test (count $argv) -ge 1
            set action $argv[1]
          end
          if test (count $argv) -ge 2
            set flake $argv[2]
          end
          if test (count $argv) -ge 3
            set host $argv[3]
          end

          echo "sudo nixos-rebuild $action --flake $flake#$host"
          sudo nixos-rebuild $action --flake $flake#$host
        '';
      };
    };

    interactiveShellInit = ''
      function fish_prompt
        set user (whoami)
        set host (hostname)
        set sym '$'
        if test "$user" = "root"
          set sym '#'
        end
        if test -n "$CONTAINER_ID"
          set distro "-$CONTAINER_ID"
        else
          set distro ""
        end

        set cB (set_color "${blue}")
        set cW (set_color "${white}")
        set cM (set_color "${magenta}")
        set cG (set_color "${green}")
        set n  (set_color normal)

        set line1 (string join -- "" $cB "┌──(" $cM $user $n "@" $cM $host $cG $distro $n ")─[" $cM (prompt_pwd) $n "]")
        set line2 (string join -- "" $cB "└─" $cM $sym " " $n)

        echo \n$line1
        echo $line2
      end
      
      if type -q pay-respects 
        pay-respects fish --alias | source
      end
    '';
  };
}