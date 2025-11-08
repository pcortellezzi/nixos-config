{
  pkgs, inputs, ...
}:
let
  original-niri-package = inputs.niri-override.packages.${pkgs.stdenv.hostPlatform.system}.niri;
  niri-package = original-niri-package.overrideAttrs (old: {
    postInstall = ''
      install -Dm644 resources/niri.desktop -t $out/share/wayland-sessions
      install -Dm644 resources/niri-portals.conf -t $out/share/xdg-desktop-portal
      
      install -Dm755 resources/niri-session $out/bin/niri-session
      install -Dm644 resources/niri{.service,-shutdown.target} -t $out/share/systemd/user
    '';
  });
in
{
  imports = [
    ../services/bluetooth.nix
    ../services/displaylink.nix
    ../services/logid.nix
    ../services/pipewire.nix
    ../services/printing.nix
    ../services/tailscale.nix
  ];

  services.xserver.enable = true;

  programs.dankMaterialShell.greeter = {
    enable = true;
    compositor.name = "niri";
  };

  programs.niri = {
    package = niri-package;
    enable = true;
  };

  environment.variables = {
    KWIN_DRM_PREFER_COLOR_DEPTH = "24";
  };

  services.desktopManager.plasma6.enable = true;
}
