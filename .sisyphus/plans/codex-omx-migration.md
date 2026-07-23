# Plan: Migration lazycodex → oh-my-codex (OMX)

## TL;DR

> **Résumé**: Remplacer l'activation script LazyCodex (oh-my-openagent) par oh-my-codex (OMX) dans le module home-manager codex.nix
>
> **Livrables**:
> - Modification de `home/philippe/codex.nix` — activation script lazycodex → OMX
>
> **Effort**: Trivial (~1 tâche)
> **Exécution**: Séquentielle

---

## Contexte

### État actuel
Le module `codex.nix` contient un activation script home-manager qui installe LazyCodex via :
```bash
npx --yes --package oh-my-openagent@latest omo install --platform=codex --no-tui --codex-autonomous
```

### Cible
Remplacer par l'installation d'OMX (oh-my-codex) :
```bash
npm install -g oh-my-codex && omx setup --scope user
```

### Pourquoi
- OMX (32k⭐) est plus complet que lazycodex (2.8k⭐)
- Model routing automatique (spark → default → xhigh) selon la complexité
- Team mode, durable goals, HUD tmux, MCP servers
- L'utilisateur garde le contrôle total en chat standard

---

## Objectifs

### Objectif principal
Remplacer LazyCodex par OMX dans la config home-manager.

### Doit avoir
- ✅ Activation script modifié : `npm install -g oh-my-codex && omx setup --scope user`
- ✅ `nix flake check` passe
- ✅ Node.js toujours présent dans home.packages (déjà le cas)

### Ne doit PAS avoir
- ❌ Pas toucher au package `pkgs/codex` dans my-nixpkgs (OK)
- ❌ Pas toucher à `flake.nix` (OK)
- ❌ Pas modifier les secrets ou autres modules

---

## Exécution

### Tâche unique

- [x] 1. Modifier `home/philippe/codex.nix`

  **Quoi faire**:
  - Lire le fichier actuel
  - Remplacer l'activation script LazyCodex par OMX
  - Le wrapper `codexWrapped` a déjà été supprimé (étape précédente), donc le fichier est déjà propre

  **Nouvel activation script**:
  ```nix
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
  ```

  **Changements clés**:
  - `home.activation.lazycodex` → `home.activation.omx`
  - `npx --yes --package oh-my-openagent@latest omo install --platform=codex` → `npm install -g oh-my-codex && npx oh-my-codex setup --scope user`
  - Condition changée : `[ ! -f "$HOME/.codex/config.toml" ]` → `! command -v omx &> /dev/null`

  **Références**:
  - `home/philippe/codex.nix` — fichier actuel

  **Critères d'acceptation**:
  - `nix flake check` → OK
  - Le fichier ne contient plus aucune référence à `oh-my-openagent`, `lazycodex`, ou `omo`

  **Scénarios QA**:
  ```
  Scenario: Vérification du module modifié
    Tool: bash
    Preconditions: codex.nix modifié
    Steps:
      1. grep -c "oh-my-openagent\|lazycodex\|omo" home/philippe/codex.nix
    Expected Result: 0 occurrences
    Evidence: .sisyphus/evidence/task-1-no-legacy-refs.log

  Scenario: nix flake check
    Tool: bash
    Preconditions: codex.nix modifié
    Steps:
      1. nix flake check 2>&1
    Expected Result: all checks passed
    Evidence: .sisyphus/evidence/task-1-flake-check.log
  ```

  **Commit**: OUI
  - Message: `codex: migrate from lazycodex to oh-my-codex (OMX)`
  - Fichiers: `home/philippe/codex.nix`

---

## Vague de vérification finale

- [x] F1. **Vérification rapide** — Lire le fichier modifié + `nix flake check`
  - Plus aucune référence à lazycodex/oh-my-openagent
  - OMX references correctes

---

## Critères de succès

- [ ] `codex.nix` ne référence plus lazycodex/oh-my-openagent
- [ ] `nix flake check` → OK
- [ ] Activation script installe OMX au prochain home-manager switch
