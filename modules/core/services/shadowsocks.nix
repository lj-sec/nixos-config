{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    shadowsocks-rust
    proxychains-ng
  ];

  systemd.user.services.sslocal = {
    description = "Shadowsocks local client";
    after = [ "network-online.target" ];
    wantedBy = [ "default.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.shadowsocks-rust}/bin/sslocal -c %h/.config/shadowsocks-rust/config.json";
      Restart = "on-failure";
      RestartSec = 3;
    };
  };
}