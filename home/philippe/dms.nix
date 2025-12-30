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
}
