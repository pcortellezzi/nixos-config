{ pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    codex
    nodejs        # Pour npm / OMX
    bubblewrap    # sandbox
    ripgrep       # grep amélioré pour codex
  ];

  # Activation script pour oh-my-codex (OMX) — une seule fois après déploiement
  home.activation.omx = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if ! command -v omx &> /dev/null; then
      $VERBOSE_ECHO "Installing oh-my-codex (OMX)..."
      ${pkgs.nodejs}/bin/npm install -g oh-my-codex 2>/dev/null || true
      ${pkgs.nodejs}/bin/npx oh-my-codex setup --scope user 2>/dev/null || $VERBOSE_ECHO "OMX setup deferred (run manually: omx setup)"
    fi
  '';
}
