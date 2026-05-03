{ config, pkgs, inputs, lib, ... }:

let
  opencodePkg = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.opencode;

  opencodeWrapped = pkgs.writeShellScriptBin "opencode" ''
    export OPENCODE_GO_API_KEY=$(cat ${config.age.secrets.opencode_go_api_key.path})
    exec ${opencodePkg}/bin/opencode "$@"
  '';

  opencodeTuiConfig = {
    "$schema" = "https://opencode.ai/tui.json";
    plugin = [
      [
        "@renjfk/opencode-voice"
        {
          endpoint = "https://opencode.ai/zen/go/v1";
          model = "deepseek-v4-flash";
          apiKeyEnv = "OPENCODE_GO_API_KEY";
          maxTokens = 2048;
        }
      ]
    ];
  };
in
{
  age.secrets.opencode_go_api_key = {
    file = ./secrets/opencode_go_api_key.age;
  };

  home.packages = with pkgs; [
    whisper-cpp
    piper-tts
    sox
    opencodeWrapped
  ] ++ (with inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; [
    oh-my-opencode
  ]);

  xdg.configFile."opencode/tui.json".text = builtins.toJSON opencodeTuiConfig;
}
