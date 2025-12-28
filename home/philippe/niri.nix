{ ... }:

{
  xdg.configFile."niri/outputs.kdl".text = ''
    output "LG Electronics LG HDR WQHD 204NTHMB9585" {
      mode width=3440 height=1440 refresh=100.0
      position x=0 y=0
      scale 1.0
    }
    output "LG Electronics LG HDR WQHD 204NTABB9600" {
      mode width=3440 height=1440 refresh=100.0
      position x=0 y=1440
      scale 1.0
    }
    output "Iiyama North America PL2730Q 1219930721568" {
      mode width=2560 height=1440 refresh=60.0
      position x=3440 y=0
      scale 1.0
    }
    output "eDP-1" {
      mode width=2880 height=1620 refresh=120.0
      position x=4880 y=1234
      scale 1.75
    }
  '';
}
