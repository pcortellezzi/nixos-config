{
  config, pkgs, inputs, ...
}:

let
  inherit (inputs) llm-agents;
in
{
  imports = [
    inputs.plasma-manager.homeModules.plasma-manager
    ./plasma.nix
  ];

  home.packages = with pkgs; [
    ((motivewave.override {
      licenseFile = config.age.secrets.motivewave_license.path;
    }).overrideAttrs (old: {
      version = "7.0.24";
      src = pkgs.fetchurl {
        url = "https://downloads.motivewave.com/builds/638/motivewave_7.0.24_amd64.deb";
        sha256 = "173j733xx5dnhrk6jw39bwnh6by3sdi2d30rfwcfr5r41mdagkwc";
      };
    }))
    google-chrome
    vlc
    tradingview
    tealstreet
    wine-wayland
    winetricks
    nodejs_24
    unrar
    zoom-us
    proton-vpn
    sublime-merge
    calibre
    obs-studio
    zed-editor
    obsidian
    kdePackages.skanlite
    kdePackages.krfb
    tigervnc
  ] ++ (with llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; [
    auto-claude
    gemini-cli
    claude-code
  ]);

  age.secrets.motivewave_license = {
    file = ./secrets/motivewave_license.age;
  };


  xdg.desktopEntries."remote-vvb" = {
    name = "Écran étendu vvb";
    comment = "Connexion RDP à l'écran virtuel de vvb";
    exec = "vncviewer -FullScreen vvb:5901";
    icon = "video-display";
    categories = [ "Network" "RemoteAccess" ];
    terminal = false;
    startupNotify = true;
  };
}