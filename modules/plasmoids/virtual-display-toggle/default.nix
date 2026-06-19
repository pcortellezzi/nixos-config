{ stdenvNoCC, lib }:

stdenvNoCC.mkDerivation {
  pname = "plasmoid-virtual-display-toggle";
  version = "1.0";

  src = lib.cleanSource ./.;

  phases = [ "installPhase" ];

  installPhase = ''
    mkdir -p $out/share/plasma/plasmoids/org.cortellezzi.virtualdisplaytoggle
    cp -r $src/metadata.json $out/share/plasma/plasmoids/org.cortellezzi.virtualdisplaytoggle/
    cp -r $src/contents $out/share/plasma/plasmoids/org.cortellezzi.virtualdisplaytoggle/
  '';
}
