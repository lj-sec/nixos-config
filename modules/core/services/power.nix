{ lib, hostProfile ? "desktop", ... }:
let
  isLaptop = hostProfile == "laptop";
in
{
  services.cpupower-gui.enable = true;
  services.power-profiles-daemon.enable = lib.mkDefault (!isLaptop);

  services.tlp = lib.mkIf isLaptop {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "schedutil";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

      PLATFORM_PROFILE_ON_AC = "balanced";
      PLATFORM_PROFILE_ON_BAT = "low-power";

      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;

      PCIE_ASPM_ON_AC = "default";
      PCIE_ASPM_ON_BAT = "powersupersave";

      # ThinkPads use 0 to disable the start threshold and charge on AC.
      # TLP requires both thresholds to apply the 90% charge limit.
      START_CHARGE_THRESH_BAT0 = 0;
      STOP_CHARGE_THRESH_BAT0 = 90;
    };
  };
}
