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
  ] ++ (with llm-agents; [
    gemini-cli
    claude-code
    claude-code-router
  ]);

  age.secrets.motivewave_license = {
    file = ./secrets/motivewave_license.age;
  };
}
