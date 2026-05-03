{ config, pkgs, inputs, lib, ... }:

let
  opencodePkg = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.opencode;

  opencodeWrapped = pkgs.writeShellScriptBin "opencode" ''
    export OPENCODE_GO_API_KEY=$(cat ${config.age.secrets.opencode_go_api_key.path})
    exec ${opencodePkg}/bin/opencode "$@"
  '';

  # Modèles pour opencode-voice (téléchargés une fois dans le nix store)
  whisperModel = pkgs.fetchurl {
    name = "ggml-large-v3-turbo-q5_0.bin";
    url = "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-large-v3-turbo-q5_0.bin";
    sha256 = "1qm7zxamlvac564c3270wqqqks5wc7532q3fqi01zbfmkiq22hir";
  };

  piperVoice = pkgs.fetchurl {
    name = "en_US-ryan-high.onnx";
    url = "https://huggingface.co/rhasspy/piper-voices/resolve/main/en/en_US/ryan/high/en_US-ryan-high.onnx";
    sha256 = "1jjf2nxn1zyih00jwh8c3bg65wblf1ha8w5spy6yr0z10rv0v6dk";
  };

  piperVoiceJson = pkgs.fetchurl {
    name = "en_US-ryan-high.onnx.json";
    url = "https://huggingface.co/rhasspy/piper-voices/resolve/main/en/en_US/ryan/high/en_US-ryan-high.onnx.json";
    sha256 = "04c0ni1qb8jw7p6l1fb47i81njgzqh7xaj8dpyzb8p1i127vkly6";
  };

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

  home.file = {
    ".local/share/whisper-cpp/ggml-large-v3-turbo-q5_0.bin".source = whisperModel;
    ".local/share/piper-voices/en_US-ryan-high.onnx".source = piperVoice;
    ".local/share/piper-voices/en_US-ryan-high.onnx.json".source = piperVoiceJson;
  };

  xdg.configFile."opencode/tui.json".text = builtins.toJSON opencodeTuiConfig;
}
