{
  config, pkgs, inputs, ...
}:

let
  inherit (inputs) llm-agents;
in
{
  imports = [
    ./niri+dms.nix
    ./plasma.nix
  ];

  home.packages = with pkgs; [
    (motivewave.override {
      licenseFile = config.age.secrets.motivewave_license.path;
    })
    google-chrome
    vlc
    tradingview
    wine
    nodejs_24
    unrar
    zoom-us
    protonvpn-gui
    sublime-merge
    zed-editor
  ] ++ (with llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; [
    auto-claude
    gemini-cli
    claude-code
    claude-code-router
  ]);

  age.secrets.motivewave_license = {
    file = ./secrets/motivewave_license.age;
  };
}