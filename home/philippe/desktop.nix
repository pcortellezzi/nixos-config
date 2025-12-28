{
  config, pkgs, inputs, ...
}:

let
  inherit (inputs) llm-agents;
in
{
  imports = [
    ./niri.nix
  ];

  home.packages = with pkgs; [
    (motivewave.override {
      licenseFile = config.age.secrets.motivewave_license.path;
    })
    google-chrome
    vlc
    tradingview
    jetbrains.rust-rover
    jetbrains.gateway
    jetbrains-runner
    vdhcoapp
    wine
    nodejs_24
    unrar
    zoom-us
    protonvpn-gui
    sublime-merge
  ] ++ (with llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; [
    gemini-cli
    claude-code
    claude-code-router
    zed-editor
  ]);

  age.secrets.motivewave_license = {
    file = ./secrets/motivewave_license.age;
  };
}