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

  # Script pour switcher de preset OMO
  omo-preset = pkgs.writeShellScriptBin "omo-preset" ''
    PRESETS_DIR="$HOME/.config/opencode/presets"
    TARGET="$HOME/.config/opencode/oh-my-openagent.json"

    if [ $# -eq 0 ]; then
      echo "Presets disponibles :"
      for f in "$PRESETS_DIR"/*.json; do
        name=$(basename "$f" .json | sed 's/^oh-my-openagent-//')
        if [ "$f" -ef "$TARGET" ] 2>/dev/null; then
          echo "  ✅ $name"
        else
          echo "     $name"
        fi
      done
      echo ""
      echo "Usage : omo-preset <nom>"
      exit 0
    fi

    PRESET="$PRESETS_DIR/oh-my-openagent-$1.json"
    if [ ! -f "$PRESET" ]; then
      echo "❌ Preset '$1' introuvable"
      echo "Disponibles : $(for f in "$PRESETS_DIR"/*.json; do basename "$f" .json | sed 's/^oh-my-openagent-//'; done | tr '\n' ' ')"
      exit 1
    fi

    rm -f "$TARGET"
    cp "$PRESET" "$TARGET"
    echo "✅ Switché vers le preset '$1'"
  '';
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
    omo-preset
  ] ++ (with inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; [
    oh-my-opencode
  ]);

  home.file = {
    ".local/share/whisper-cpp/ggml-large-v3-turbo-q5_0.bin".source = "${voiceModels}/share/opencode-voice/whisper/ggml-large-v3-turbo-q5_0.bin";
    ".local/share/piper-voices/en_US-ryan-high.onnx".source = "${voiceModels}/share/opencode-voice/piper/en_US-ryan-high.onnx";
    ".local/share/piper-voices/en_US-ryan-high.onnx.json".source = "${voiceModels}/share/opencode-voice/piper/en_US-ryan-high.onnx.json";

    # Presets OMO (toujours déployés)
    ".config/opencode/presets/oh-my-openagent-devpass.json".source = ./opencode-config/oh-my-openagent-devpass.json;
    ".config/opencode/presets/oh-my-openagent-gocode.json".source = ./opencode-config/oh-my-openagent-gocode.json;

    # Lien actif — créé seulement si inexistant (force = false)
    ".config/opencode/oh-my-openagent.json" = {
      source = ./opencode-config/oh-my-openagent-devpass.json;
      force = false;
    };
  };

  xdg.configFile = {
    "opencode/tui.json".text = builtins.toJSON opencodeTuiConfig;

    "opencode/opencode.json" = {
      source = ./opencode-config/opencode.json;
      force = true;
    };
    "opencode/AGENTS.md".source = ./opencode-config/AGENTS.md;
  };
}
