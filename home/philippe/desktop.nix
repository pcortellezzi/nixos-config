{
  config, pkgs, pkgs-unstable, ...
}:

{
  home.packages = with pkgs; [
    kdePackages.skanpage
    (motivewave.override {
      licenseFile = config.age.secrets.motivewave_license.path;
    })
  ] ++ (with pkgs-unstable; [
    google-chrome
    vlc
    gemini-cli
    tradingview
    jetbrains.rust-rover
    jetbrains.gateway
    jetbrains-runner
    vscode
    (vscode-extensions.ms-vscode-remote.remote-containers)
    vdhcoapp
    wine
    rustup
    gcc
    lldb
  ]);

  services.podman.enable = true;

  age.secrets.motivewave_license = {
    file = ./secrets/motivewave_license.age;
  };
}
