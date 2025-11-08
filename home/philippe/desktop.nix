{
  config, pkgs, pkgs-unstable, ...
}:

{
  imports = [
    ../../modules/home-manager/dms-niri.nix
  ];

  home.packages = with pkgs; [
    kdePackages.skanpage
    (motivewave.override {
      licenseFile = config.age.secrets.motivewave_license.path;
    })
  ] ++ (with pkgs-unstable; [
    google-chrome
    vlc
    tradingview
    jetbrains.rust-rover
    jetbrains.gateway
    jetbrains-runner
    vscode
    (vscode-extensions.ms-vscode-remote.remote-containers)
    vdhcoapp
    wine
    nodejs_24
    unrar
  ]);

  services.podman.enable = true;

  programs.bash.shellAliases = {
    gemini = "npx @google/gemini-cli";
  };

  age.secrets.motivewave_license = {
    file = ./secrets/motivewave_license.age;
  };
}
