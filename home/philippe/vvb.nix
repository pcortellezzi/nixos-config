{ config, lib, pkgs, ... }:

let
  startupIni = pkgs.writeText "motivewave-startup.ini" ''
    # MotiveWave startup configuration for vvb
    # AMD Ryzen 9 7940HS | 32GB RAM | NVIDIA RTX 4050 6GB VRAM
    MAX_HEAP=8G
    MAX_VRAM=3072M
    VM_ARGS=-XX:+UseZGC -XX:+ZGenerational -XX:ZAllocationSpikeTolerance=2.0
  '';
in {
  home.file.".motivewave/startup.ini" = {
    source = startupIni;
    force = true;
  };

  xdg.desktopEntries."motivewave" = {
    name = "MotiveWave";
    exec = "env __NV_PRIME_RENDER_OFFLOAD=1 __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0 __GLX_VENDOR_LIBRARY_NAME=nvidia __VK_LAYER_NV_optimus=NVIDIA_only motivewave %F";
  };
}
