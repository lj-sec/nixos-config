{ ... }: {
  time.timeZone = "America/New_York";
  services.timesyncd.enable = true;
  # Or chrony if you prefer:
  # services.chrony.enable = true;
}