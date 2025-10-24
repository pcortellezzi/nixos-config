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
    vscode
    (vscode-extensions.ms-vscode-remote.remote-containers)
    podman
    podman-compose
    vdhcoapp
    wine
  ]);

  age.secrets.motivewave_license = {
    file = ./secrets/motivewave_license.age;
  };

  

  programs.firefox.enable = true;
}
