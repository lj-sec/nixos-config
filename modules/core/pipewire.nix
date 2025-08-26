{ pkgs, ... }:
{
  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };
  environment.systemPackages = with pkgs; [ pulseaudioFull ];
}
