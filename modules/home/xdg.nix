{ ... }:
{
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      # Browser
      "text/html" = "com.brave.Browser.desktop";
      "application/xhtml+xml" = "com.brave.Browser.desktop";
      "x-scheme-handler/http" = "com.brave.Browser.desktop";
      "x-scheme-handler/https" = "com.brave.Browser.desktop";
      "x-scheme-handler/about" = "com.brave.Browser.desktop";
      "x-scheme-handler/unknown" = "com.brave.Browser.desktop";

      # Optional, but useful if Brave should handle browser-ish links
      "x-scheme-handler/chrome" = "com.brave.Browser.desktop";

      # File manager
      "inode/directory" = "nemo.desktop";

      # Slack
      "x-scheme-handler/slack" = "slack.desktop";

      # Images
      "image/png" = "imv-dir.desktop";
      "image/apng" = "imv-dir.desktop";
      "image/jpeg" = "imv-dir.desktop";
      "image/jpg" = "imv-dir.desktop";
      "image/gif" = "imv-dir.desktop";
      "image/webp" = "imv-dir.desktop";
      "image/bmp" = "imv-dir.desktop";
      "image/x-bmp" = "imv-dir.desktop";
      "image/tiff" = "imv-dir.desktop";
      "image/svg+xml" = "imv-dir.desktop";
      "image/avif" = "imv-dir.desktop";
      "image/heic" = "imv-dir.desktop";
      "image/heif" = "imv-dir.desktop";
      "image/vnd.microsoft.icon" = "imv-dir.desktop";
      "image/x-icon" = "imv-dir.desktop";

      # Videos
      "video/mp4" = "mpv.desktop";
      "video/x-m4v" = "mpv.desktop";
      "video/x-matroska" = "mpv.desktop";
      "video/webm" = "mpv.desktop";
      "video/quicktime" = "mpv.desktop";
      "video/x-msvideo" = "mpv.desktop";
      "video/x-ms-wmv" = "mpv.desktop";
      "video/mpeg" = "mpv.desktop";
      "video/ogg" = "mpv.desktop";
      "video/x-ogm+ogg" = "mpv.desktop";
      "video/x-flv" = "mpv.desktop";
      "video/3gpp" = "mpv.desktop";
      "video/3gpp2" = "mpv.desktop";
      "video/mp2t" = "mpv.desktop";
    };
  };
}