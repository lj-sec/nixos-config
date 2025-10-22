{ pkgs, config, username, ... }:
{
  imports = [
    ./swap.nix
    ./hardware-configuration.nix
    ./../../modules/core
  ];

  boot.initrd.kernelModules = [ "amdgpu" ];
  services.xserver.videoDrivers = [ "amdgpu" ];

  hardware.graphics = {
    enable = true;          # replaces hardware.opengl.enable
    enable32Bit = true;     # 32-bit GL/VK for Steam/Proton
    extraPackages = with pkgs; [
      vulkan-tools          # vulkaninfo
      mesa-demos            # glxinfo, glxgears
      vaapiVdpau            # VA-API → VDPAU bridge
      libvdpau-va-gl        # VDPAU over VA-API
      # rocm-opencl-icd     # uncomment if you want OpenCL
      # amdvlk              # optional; Mesa’s RADV is default and usually better
    ];
  };

  hardware.enableRedistributableFirmware = true;
}
