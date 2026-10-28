{ ... }:

{
  programs.fish = {
    enable = true;

    shellAliases = {
      l = "eza -alh";
      ll = "eza -l";
      ls = "eza";
      gs = "git status";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      ngc = "nix-collect-garbage -d";
      grep = "grep --color=auto";
    };

    functions = {
      fish_greeting.body = ''
        if command -q fastfetch
          status --is-interactive; and test -t 1
          fastfetch
        end
      '';

      rebuild = {
        description = "Run nix-on-droid switch for this flake";
        body = ''
          set -l flake .

          if test (count $argv) -ge 1
            set flake $argv[1]
          end

          echo "nix-on-droid switch --flake $flake"
          nix-on-droid switch --flake "$flake"
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
          set -l src_re (string escape --style=regex -- "$src_abs")

          if string match -qr "^$src_re(/|\$)" -- "$out_abs"
              echo "Output directory must not be inside the source directory."
              return 1
          end

          mkdir -p "$out_abs"

          set -l manifest (mktemp)
          set -l sorted_manifest (mktemp)

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
                  set part_count (math "$part_count + 1")
                  mkdir -p "$out_abs/part$part_count"
                  cp -a "$item" "$out_abs/part$part_count"/
                  set -a bucket_sizes $size

                  if test "$size" -gt "$max_bytes"
                      echo "Warning: directory '$base' is larger than MAX_SIZE and was placed in its own part unchanged."
                  end

                  continue
              end

              set -l target_bucket 0

              for i in (seq 1 $part_count)
                  set -l proposed (math "$bucket_sizes[$i] + $size")
                  if test "$proposed" -le "$max_bytes"
                      set target_bucket $i
                      break
                  end
              end

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
    };

    interactiveShellInit = ''
      function fish_prompt
        set -l last_status $status
        set -l user "$USER"
        if test -z "$user"
          set user (id -un)
        end

        set -l sym '$'
        if test (id -u) -eq 0
          set sym '#'
        end

        set -l c_blue (set_color "#89b4fa")
        set -l c_magenta (set_color "#cba6f7")
        set -l c_green (set_color "#a6e3a1")
        set -l c_red (set_color "#f38ba8")
        set -l n (set_color normal)

        printf "\n%s┌──(%s%s%s@%s%s%s)─[%s%s%s]" $c_blue $c_magenta "$user" $n $c_magenta (prompt_hostname) $n $c_magenta (prompt_pwd) $n
        if test "$last_status" -ne 0
          printf " %s[%s]%s" $c_red "$last_status" $n
        end

        printf "\n%s└─%s%s %s" $c_blue $c_magenta "$sym" $n
      end

      if type -q pay-respects
        pay-respects fish --alias | source
      end
    '';
  };
}
