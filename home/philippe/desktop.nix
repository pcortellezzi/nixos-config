{
  config, pkgs, inputs, ...
}:

let
  inherit (inputs) llm-agents;
in
{
  imports = [
    ./hyprland+dms.nix
    ./plasma.nix
    ./gnome.nix
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
  ] ++ (with llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; [
    auto-claude
    gemini-cli
    claude-code
  ]);

  age.secrets.motivewave_license = {
    file = ./secrets/motivewave_license.age;
  };
}