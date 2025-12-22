{
  config, pkgs, llm-agents, ...
}:

{
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
  ] ++ (with llm-agents.packages.${pkgs.system}; [
    gemini-cli
    claude-code
    claude-code-router
    zed-editor
  ]);

  age.secrets.motivewave_license = {
    file = ./secrets/motivewave_license.age;
  };
}
