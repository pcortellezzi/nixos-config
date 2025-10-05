{
  config, pkgs, pkgs-unstable, ...
}:

{
  home.packages = with pkgs; [
    (motivewave.override {
      licenseFile = config.age.secrets.motivewave_license.path;
    })
  ] ++ (with pkgs-unstable; [
    google-chrome
    vlc
    gemini-cli
    tradingview
    vscode
    (vscode-extensions.ms-vscode-remote.remote-containers)
    podman
    podman-compose
    vdhcoapp
  ]);

  age.secrets.motivewave_license = {
    file = ./secrets/motivewave_license.age;
  };

  

  programs.firefox.enable = true;
}
