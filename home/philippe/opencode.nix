{ config, pkgs, inputs, lib, ... }:

let
  opencodePkg = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.opencode;

  opencodeWrapped = pkgs.writeShellScriptBin "opencode" ''
    export OPENCODE_GO_API_KEY=$(cat ${config.age.secrets.opencode_go_api_key.path})
    export NODE_PATH=${pkgs.opencode-plugins}/lib/node_modules
    exec ${opencodePkg}/bin/opencode "$@"
  '';

  # Modèles pour opencode-voice (depuis my-nixpkgs, mis en cache par cachix)
  voiceModels = pkgs.opencode-voice-models;

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
    nodejs
    whisper-cpp
    piper-tts
    sox
    opencodeWrapped
    opencode-plugins
  ] ++ (with inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; [
    oh-my-opencode
  ]);

  home.file = {
    ".local/share/whisper-cpp/ggml-large-v3-turbo-q5_0.bin".source = "${voiceModels}/share/opencode-voice/whisper/ggml-large-v3-turbo-q5_0.bin";
    ".local/share/piper-voices/en_US-ryan-high.onnx".source = "${voiceModels}/share/opencode-voice/piper/en_US-ryan-high.onnx";
    ".local/share/piper-voices/en_US-ryan-high.onnx.json".source = "${voiceModels}/share/opencode-voice/piper/en_US-ryan-high.onnx.json";
  };

  xdg.configFile = {
    "opencode/tui.json".text = builtins.toJSON opencodeTuiConfig;

    "opencode/opencode.json" = {
      source = ./opencode-config/opencode.json;
      force = true;
    };
    "opencode/AGENTS.md".source = ./opencode-config/AGENTS.md;
    "opencode/oh-my-openagent.json".source = ./opencode-config/oh-my-openagent.json;
  };
}
