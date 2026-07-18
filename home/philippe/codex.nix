{ config, pkgs, inputs, lib, ... }:

let
  codexWrapped = pkgs.writeShellScriptBin "codex" ''
    export OPENAI_API_KEY=$(cat ${config.age.secrets.codex_api_key.path})
    exec ${pkgs.codex}/bin/codex "$@"
  '';
in
{
  age.secrets.codex_api_key = {
    file = ./secrets/codex_api_key.age;
  };

  home.packages = with pkgs; [
    codexWrapped
    nodejs        # Pour npx / lazycodex
    bubblewrap    # sandbox
    ripgrep       # grep amélioré pour codex
  ];

  # Activation script pour LazyCodex (une seule fois après déploiement)
  home.activation.lazycodex = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if [ ! -f "$HOME/.codex/config.toml" ]; then
      $VERBOSE_ECHO "Installing LazyCodex harness..."
      export OPENAI_API_KEY=$(cat ${config.age.secrets.codex_api_key.path})
      ${pkgs.nodejs}/bin/npx --yes --package oh-my-openagent@latest omo install --platform=codex --no-tui --codex-autonomous 2>/dev/null || $VERBOSE_ECHO "LazyCodex install deferred (run manually: npx lazycodex-ai install)"
    fi
  '';
}
