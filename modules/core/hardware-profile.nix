{ config, lib, driverProfile ? "auto", ... }:
let
  validProfiles = [
    "auto"
    "none"
    "amd"
    "intel"
    "nvidia"
    "vm"
  ];

  videoDrivers = {
    amd = [ "amdgpu" ];
    intel = [ "modesetting" ];
    nvidia = [ "nvidia" ];
    vm = [ "modesetting" ];
  }.${driverProfile} or [ ];
in
{
  assertions = [
    {
      assertion = builtins.elem driverProfile validProfiles;
      message = "Unknown driver profile '${driverProfile}'. Use one of: ${lib.concatStringsSep ", " validProfiles}.";
    }
  ];

  hardware.graphics = {
    enable = lib.mkDefault (driverProfile != "none");
    enable32Bit = lib.mkDefault (builtins.elem driverProfile [
      "amd"
      "intel"
      "nvidia"
    ]);
  };

  services.xserver.videoDrivers = lib.mkIf (videoDrivers != [ ]) videoDrivers;

  hardware.nvidia = lib.mkIf (driverProfile == "nvidia") {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.production;
  };

  environment.variables.VK_ICD_FILENAMES = lib.mkIf (driverProfile == "nvidia")
    "/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.x86_64.json:/run/opengl-driver-32/share/vulkan/icd.d/nvidia_icd.i686.json";

  services.qemuGuest.enable = lib.mkIf (driverProfile == "vm") true;
  services.spice-vdagentd.enable = lib.mkIf (driverProfile == "vm") true;
}
