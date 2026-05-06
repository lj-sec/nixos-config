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
      gc = "sudo nix-collect-garbage -d";
      gpssl = "sudo gpclient --fix-openssl connect";
    };

    functions = {
      fish_greeting.body = ''
        if command -q fastfetch
          status --is-interactive; and test -t 1
          fastfetch
        end
      '';

      sudo = {
        description = "Replacement for Bash 'sudo !!' command to run last command using sudo";
        body = ''
          if test "$argv" = !!
              echo sudo $history[1]
              eval command sudo $history[1]
          else
              command sudo $argv
          end
        '';
      };

      split_dir = {
        description = "split_dir <SRC> <OUTDIR> <MAX_SIZE>";
        body = ''
          set -l src $argv[1]
          set -l outdir $argv[2]
          set -l max_size_raw (string lower -- $argv[3])

          if test (count $argv) -ne 3
              echo "Usage: split_dir <SRC> <OUTDIR> <MAX_SIZE>"
              echo "Example: split_dir ./data ./output 50MB"
              return 1
          end

          if not test -d "$src"
              echo "Not a directory: $src"
              return 1
          end

          # Parse size strings like:
          # 50, 50b, 50kb, 50mb, 50gb, 50kib, 50mib, 1.5gb
          if not string match -qr '^[0-9]+(\.[0-9]+)?([kmgtp]?i?b?)?$' -- "$max_size_raw"
              echo "Invalid MAX_SIZE: $argv[3]"
              echo "Examples: 50000, 50MB, 50MiB, 1.5GB"
              return 1
          end

          set -l max_num (string replace -r '^([0-9]+(\.[0-9]+)?).*' '$1' -- "$max_size_raw")
          set -l max_unit (string replace -r '^[0-9]+(\.[0-9]+)?' "" -- "$max_size_raw")
          set -l multiplier 1

          switch "$max_unit"
              case "" b
                  set multiplier 1
              case k kb
                  set multiplier 1000
              case m mb
                  set multiplier 1000000
              case g gb
                  set multiplier 1000000000
              case t tb
                  set multiplier 1000000000000
              case p pb
                  set multiplier 1000000000000000
              case ki kib
                  set multiplier 1024
              case mi mib
                  set multiplier 1048576
              case gi gib
                  set multiplier 1073741824
              case ti tib
                  set multiplier 1099511627776
              case pi pib
                  set multiplier 1125899906842624
              case '*'
                  echo "Unsupported size unit: $max_unit"
                  return 1
          end

          set -l max_bytes (math "floor($max_num * $multiplier)")

          if test "$max_bytes" -le 0
              echo "MAX_SIZE must be greater than 0."
              return 1
          end

          set -l src_abs (realpath "$src")
          set -l out_abs (realpath -m "$outdir")

          # Prevent recursive self-copying if OUTDIR is inside SRC
          set -l src_re (string escape --style=regex -- "$src_abs")
          if string match -qr "^$src_re(/|\$)" -- "$out_abs"
              echo "Output directory must not be inside the source directory."
              return 1
          end

          mkdir -p "$out_abs"

          set -l manifest (mktemp)
          set -l sorted_manifest (mktemp)

          # Build manifest of top-level items with recursive size.
          # Directories are measured recursively, but will be copied whole
          # into their own part rather than split further.
          find "$src_abs" -mindepth 1 -maxdepth 1 | while read -l path
              set -l size (du -sb --apparent-size "$path" | awk '{print $1}')
              printf '%s\t%s\n' "$size" "$path"
          end > "$manifest"

          sort -nr "$manifest" > "$sorted_manifest"

          set -l part_count 0
          set -l bucket_sizes

          while read -l line
              set -l fields (string split -m 1 \t -- "$line")
              set -l size $fields[1]
              set -l item $fields[2]
              set -l base (basename "$item")

              if test -d "$item"
                  # Top-level directories are treated as atomic units and always get
                  # their own part. No recursion for splitting them.
                  set part_count (math "$part_count + 1")
                  mkdir -p "$out_abs/part$part_count"
                  cp -a "$item" "$out_abs/part$part_count"/
                  set -a bucket_sizes $size

                  if test "$size" -gt "$max_bytes"
                      echo "Warning: directory '$base' is larger than MAX_SIZE and was placed in its own part unchanged."
                  end

                  continue
              end

              # For files, try to place them into the first existing bucket that fits.
              set -l target_bucket 0

              for i in (seq 1 $part_count)
                  set -l proposed (math "$bucket_sizes[$i] + $size")
                  if test "$proposed" -le "$max_bytes"
                      set target_bucket $i
                      break
                  end
              end

              # No existing bucket fits; create a new one.
              if test "$target_bucket" -eq 0
                  set part_count (math "$part_count + 1")
                  set target_bucket $part_count
                  mkdir -p "$out_abs/part$target_bucket"
                  set -a bucket_sizes 0
              end

              cp -a "$item" "$out_abs/part$target_bucket"/
              set bucket_sizes[$target_bucket] (math "$bucket_sizes[$target_bucket] + $size")

              if test "$size" -gt "$max_bytes"
                  echo "Warning: file '$base' is larger than MAX_SIZE and was placed in its own part unchanged."
              end
          end < "$sorted_manifest"

          rm -f "$manifest" "$sorted_manifest"

          echo "Done."
          echo "Source: $src_abs"
          echo "Output: $out_abs"
          echo "Max per part: $max_bytes bytes"
          for i in (seq 1 $part_count)
              echo "part$i: $bucket_sizes[$i] bytes"
          end
        '';
      };

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