{ pkgs, inputs, ... }:
let
  inherit (inputs) danksearch;
in
{
  imports = [ danksearch.homeModules.default ];

  programs.dsearch = {
    enable = true;
    config = {
      exclude = {
        directories = [ "node_modules" ".git" ".cache" "target" "build" "venv" ];
      };
      include = {
        paths = [ "/home/philippe" ];
      };
      indexing = {
        hidden = false;
      };
      search = {
        fuzzy = true;
      };
    };
  };

  home.packages = with pkgs; [
    libqalculate
  ];

  xdg.configFile."DankMaterialShell/plugins/powermenu".source = ../../modules/dms-plugins/powermenu;
  xdg.configFile."DankMaterialShell/plugins/qalculate".source = ../../modules/dms-plugins/qalculate;
}
