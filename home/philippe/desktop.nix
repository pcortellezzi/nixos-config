{
  config, pkgs, ...
}:

{
  home.packages = with pkgs; [
    vlc
    dotnet-sdk_8
    gemini-cli
    (motivewave-beta.override {
      licenseFile = config.age.secrets.motivewave_license.path;
    })
    grpc
    protobuf
    tradingview
    vscode
    (vscode-extensions.ms-vscode-remote.remote-containers)
    podman
    podman-compose
  ];

  age.secrets.motivewave_license = {
    file = ./secrets/motivewave_license.age;
  };

  

  programs.firefox.enable = true;
}
