{ installFeatures ? {}, ... }:
let
  feature = name:
    if builtins.hasAttr name installFeatures then installFeatures.${name} else true;
  browserDesktop = if feature "brave" then "com.brave.Browser.desktop" else "firefox.desktop";
  imageDesktop = if feature "media" then "imv-dir.desktop" else browserDesktop;
  videoDesktop = if feature "media" then "mpv.desktop" else browserDesktop;
in
{
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      # Browser
      "text/html" = browserDesktop;
      "application/xhtml+xml" = browserDesktop;
      "x-scheme-handler/http" = browserDesktop;
      "x-scheme-handler/https" = browserDesktop;
      "x-scheme-handler/about" = browserDesktop;
      "x-scheme-handler/unknown" = browserDesktop;

      # Optional, but useful if Brave should handle browser-ish links
      "x-scheme-handler/chrome" = browserDesktop;

      # File manager
      "inode/directory" = "nemo.desktop";

      # Slack
      "x-scheme-handler/slack" = "slack.desktop";

      # Images
      "image/png" = imageDesktop;
      "image/apng" = imageDesktop;
      "image/jpeg" = imageDesktop;
      "image/jpg" = imageDesktop;
      "image/gif" = imageDesktop;
      "image/webp" = imageDesktop;
      "image/bmp" = imageDesktop;
      "image/x-bmp" = imageDesktop;
      "image/tiff" = imageDesktop;
      "image/svg+xml" = imageDesktop;
      "image/avif" = imageDesktop;
      "image/heic" = imageDesktop;
      "image/heif" = imageDesktop;
      "image/vnd.microsoft.icon" = imageDesktop;
      "image/x-icon" = imageDesktop;

      # Videos
      "video/mp4" = videoDesktop;
      "video/x-m4v" = videoDesktop;
      "video/x-matroska" = videoDesktop;
      "video/webm" = videoDesktop;
      "video/quicktime" = videoDesktop;
      "video/x-msvideo" = videoDesktop;
      "video/x-ms-wmv" = videoDesktop;
      "video/mpeg" = videoDesktop;
      "video/ogg" = videoDesktop;
      "video/x-ogm+ogg" = videoDesktop;
      "video/x-flv" = videoDesktop;
      "video/3gpp" = videoDesktop;
      "video/3gpp2" = videoDesktop;
      "video/mp2t" = videoDesktop;
    };
  };
}
