{ config, pkgs, inputs, lib, ... }:

let
  opencodePkg = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.opencode;

  opencodeWrapped = pkgs.writeShellScriptBin "opencode" ''
    export OPENCODE_GO_API_KEY=$(cat ${config.age.secrets.opencode_go_api_key.path})
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

  # Liste des plugins npm globaux nécessaires pour la config Supreme
  npmPlugins = [
    "opencode-snippets@latest"
    "opencode-snip@latest"
    "opencode-notify@latest"
    "opencode-mem@latest"
    "opencode-quota@latest"
    "opencode-background-agents@latest"
    "opencode-worktree@latest"
    "opencode-dynamic-context-pruning@latest"
    "opencode-smart-title@latest"
    "ocwatch@latest"
    "supermemory@latest"
    "openskills@latest"
    "@ast-grep/cli@latest"
    "@colbymchenry/codegraph@latest"
  ];
in
{
  home.sessionPath = [ "$HOME/.npm-global/bin" ];

  age.secrets.opencode_go_api_key = {
    file = ./secrets/opencode_go_api_key.age;
  };

  home.packages = with pkgs; [
    nodejs
    whisper-cpp
    piper-tts
    sox
    opencodeWrapped
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

    "opencode/opencode.json".source = ./opencode-config/opencode.json;
    "opencode/AGENTS.md".source = ./opencode-config/AGENTS.md;
    "opencode/oh-my-openagent.json".source = ./opencode-config/oh-my-openagent.json;
  };

  # Activation script : installe les plugins npm globaux au premier déploiement
  # NixOS a un prefix en lecture seule → on utilise ~/.npm-global
  home.activation.installOpendodePlugins = lib.hm.dag.entryAfter ["writeBoundary"] ''
    export PATH="${pkgs.nodejs}/bin:$PATH"
    export npm_config_prefix="$HOME/.npm-global"
    export PATH="$npm_config_prefix/bin:$PATH"
    mkdir -p "$npm_config_prefix"
    if ! "$npm_config_prefix/bin/opencode-snippets" --version &>/dev/null 2>&1; then
      echo "  installing opencode npm plugins..."
      npm install -g \
        ${builtins.concatStringsSep " \\\n        " npmPlugins} \
        git+https://github.com/obra/superpowers.git \
        2>&1
    fi
  '';
}
