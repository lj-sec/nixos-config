{ pkgs, host, ... }:
{
  # Workaround to not break emergency shell
  programs.bash = {
    enable = true;
    initExtra = ''
      if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
      then
        shopt -q login_shell && LOGON_OPTION='--login' ||  LOGIN_OPTION=""
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
    };

    functions = {

      fish_greeting.body = ''
        if command -q fastfetch
          status --is-interactive; and test -t 1
          fastfetch
        end
      '';

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

          echo "sudo nixos-rebuild $action --flake $flake#host"
          sudo nixos-rebuild $action --flake $flake#$host
        '';
      };
    };

    interactiveShellInit = ''
      set -U fish_greeting
    '';
  };
}
