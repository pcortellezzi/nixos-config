{
  config, pkgs, ...
}:

{
  home.packages = with pkgs; [
    gemini-cli
    (motivewave-beta.override {
      licenseFile = config.age.secrets.motivewave_license.path;
    })
    vscode
  ];

  age.secrets.motivewave_license = {
    file = ./secrets/motivewave_license.age;
  };

  

  programs.firefox.enable = true;
}
