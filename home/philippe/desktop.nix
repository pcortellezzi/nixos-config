{
  config, pkgs, ...
}:

{
  home.packages = with pkgs; [
    dotnet-sdk_8
    gemini-cli
    (motivewave-beta.override {
      licenseFile = config.age.secrets.motivewave_license.path;
    })
    tradingview
    vscode
  ];

  age.secrets.motivewave_license = {
    file = ./secrets/motivewave_license.age;
  };

  

  programs.firefox.enable = true;
}
