{ ... }: {
  time.timeZone = "America/New_York";
  services.timesyncd = {
    enable = true;
    servers = []; # to ensure timesyncd fetches NTP servers from DHCP
  };
  environment.variables = {
    TZ = "America/New_York";
    TZDIR = "/etc/zoneinfo";
  };
}