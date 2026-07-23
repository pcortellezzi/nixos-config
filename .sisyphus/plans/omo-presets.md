# Plan: Presets OMO + script omo-preset

## TL;DR

> **Résumé**: Créer deux fichiers presets (devpass, gocode), un script `omo-preset` pour switcher, et déployer le tout via home-manager avec `force = false`
>
> **Livrables**:
> - `oh-my-openagent-devpass.json` — preset DevPass (renommer l'existant)
> - `oh-my-openagent-gocode.json` — preset Go + OpenAI
> - `omo-preset` — script bash installé dans PATH
> - Mise à jour de `opencode.nix`

---

## Exécution

- [ ] 1. Renommer `oh-my-openagent.json` → `oh-my-openagent-devpass.json`

  **Quoi faire**: `git mv oh-my-openagent.json oh-my-openagent-devpass.json` dans `home/philippe/opencode-config/`

- [ ] 2. Créer `oh-my-openagent-gocode.json`

  **Quoi faire**: Copier le fichier devpass et remplacer `devpass/` par `openai/` pour les modèles GPT, et `devpass/` par `opencode-go/` pour les autres (Kimi, GLM).

  Modèles à changer :
  | Agent | DevPass | Go + OpenAI |
  |-------|---------|-------------|
  | sisyphus | `devpass/kimi-k3` | `opencode-go/kimi-k3` |
  | hephaestus | `devpass/gpt-5.6-sol` | `openai/gpt-5.6-sol` |
  | oracle | `devpass/gpt-5.6-sol` | `openai/gpt-5.6-sol` |
  | momus | `devpass/gpt-5.6-terra` | `openai/gpt-5.6-terra` |
  | metis | `devpass/kimi-k3` | `opencode-go/kimi-k3` |
  | prometheus | `devpass/glm-5.2` | `opencode-go/glm-5.2` |
  | atlas | `devpass/kimi-k3` | `opencode-go/kimi-k3` |
  | ultrabrain | `devpass/gpt-5.6-sol` | `openai/gpt-5.6-sol` |
  | deep | `devpass/kimi-k3` | `opencode-go/kimi-k3` |
  | unspecified-high | `devpass/kimi-k3` | `opencode-go/kimi-k3` |

- [ ] 3. Mettre à jour `home/philippe/opencode.nix`

  **Quoi faire**:
  - Ajouter les deux presets en `home.file` :
    ```nix
    ".config/opencode/presets/oh-my-openagent-devpass.json".source = ./opencode-config/oh-my-openagent-devpass.json;
    ".config/opencode/presets/oh-my-openagent-gocode.json".source = ./opencode-config/oh-my-openagent-gocode.json;
    ```
  - Remplacer le `xdg.configFile` actuel par :
    ```nix
    ".config/opencode/oh-my-openagent.json" = {
      source = ./opencode-config/oh-my-openagent-devpass.json;
      force = false;
    };
    ```
  - Ajouter le script `omo-preset` dans `home.packages` :
    ```nix
    omo-preset = pkgs.writeShellScriptBin "omo-preset" ''
      PRESETS_DIR="$HOME/.config/opencode/presets"
      TARGET="$HOME/.config/opencode/oh-my-openagent.json"

      if [ $# -eq 0 ]; then
        echo "Presets disponibles :"
        for f in "$PRESETS_DIR"/*.json; do
          name=$(basename "$f" .json | sed 's/^oh-my-openagent-//')
          if [ "$(readlink -f "$f")" = "$(readlink -f "$TARGET" 2>/dev/null || echo '')" ] || [ "$f" -ef "$TARGET" ] 2>/dev/null; then
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
    ```

- [ ] 4. Vérification

  - `nix flake check` → OK
  - Vérifier que `~/.config/opencode/presets/` contient les deux fichiers
  - Vérifier que `omo-preset` liste les presets et fonctionne

---

## Critères de succès

- [ ] Deux presets créés dans le repo
- [ ] `opencode.nix` déploie les presets + script
- [ ] `force = false` → lien écrasable manuellement
- [ ] `omo-preset devpass` / `omo-preset gocode` fonctionne
- [ ] `nix flake check` OK
