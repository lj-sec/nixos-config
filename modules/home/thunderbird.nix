{ config, pkgs, ... }:

{
  programs.thunderbird = {
    package = pkgs.thunderbird-latest;

    enable = true;

    profiles.main = {
      isDefault = true;

      # Thunderbird user.js preferences for this profile
      settings = {
        "mail.spellcheck.inline" = false;
        "extensions.autoDisableScopes" = 0; # useful if you later add extensions declaratively
      };

      # Optional custom CSS
      userChrome = ''
        /* Example: hide tab bar */
        #tabs-toolbar { visibility: collapse !important; }
      '';

      # Optional extension packages (you still need to enable them once after first install)
      # extensions = [ ];
    };
  };
}