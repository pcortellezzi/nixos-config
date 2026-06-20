{
  config, pkgs, inputs, ...
}:

let
  inherit (inputs) llm-agents;
in
{
  imports = [
    ./plasma.nix
  ];

  home.packages = with pkgs; [
    (motivewave.override {
      licenseFile = config.age.secrets.motivewave_license.path;
    })
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
    tigervnc
    kdePackages.skanlite
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