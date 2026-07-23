# Plan: Mise à jour du routing OMO — DevPass + OpenCode Go

## TL;DR

> **Résumé**: Mettre à jour `oh-my-openagent.json` avec le nouveau routing modèle par agent : DevPass pour les agents premium, OpenCode Go pour le quotidien
>
> **Livrables**:
> - Modification de `home/philippe/opencode-config/oh-my-openagent.json`
>
> **Effort**: Trivial (~1 fichier)

---

## Contexte

Nouvelle stratégie de modèles :
- **OpenCode Go ($10/mo)** → deepseek-v4-flash pour les agents légers (explore, librarian, quick, caveman...)
- **DevPass Pro ($79/mo)** → modèles premium pour les agents stratégiques

La répartition suit les recommandations OMO pour chaque agent.

---

## Objectifs

### Doit avoir
- ✅ Routing mis à jour dans `oh-my-openagent.json`
- ✅ `nix flake check` OK

### Ne doit PAS avoir
- ❌ Pas toucher aux autres fichiers
- ❌ Pas casser la config existante

---

## Exécution

- [x] 1. Modifier `home/philippe/opencode-config/oh-my-openagent.json`

  **Quoi faire**:
  - Remplacer le fichier avec la nouvelle config ci-dessous
  - Uniquement les `agents` et `categories` changent — le reste du fichier reste identique

  **Nouvelle config agents**:
  ```json
  {
    "sisyphus":      { "model": "devpass/kimi-k3" },
    "hephaestus":    { "model": "devpass/gpt-5.6-sol", "variant": "medium" },
    "oracle":        { "model": "devpass/gpt-5.6-sol", "variant": "high" },
    "momus":         { "model": "devpass/gpt-5.6-terra", "variant": "high" },
    "metis":         { "model": "devpass/kimi-k3" },
    "prometheus":    { "model": "devpass/glm-5.2" },
    "atlas":         { "model": "devpass/kimi-k3" },
    "explore":       { "model": "opencode-go/deepseek-v4-flash" },
    "librarian":     { "model": "opencode-go/deepseek-v4-flash" },
    "quick":         { "model": "opencode-go/deepseek-v4-flash" },
    "caveman":       { "model": "opencode-go/deepseek-v4-flash" },
    "sisyphus-junior": { "model": "opencode-go/deepseek-v4-flash" }
  }
  ```

  **Nouvelle config categories**:
  ```json
  {
    "ultrabrain":        { "model": "devpass/gpt-5.6-sol", "variant": "xhigh" },
    "deep":              { "model": "devpass/kimi-k3" },
    "unspecified-high":  { "model": "devpass/kimi-k3" },
    "unspecified-low":   { "model": "opencode-go/deepseek-v4-flash" },
    "visual-engineering": { "model": "opencode-go/qwen3.6-plus" },
    "writing":           { "model": "opencode-go/deepseek-v4-flash" },
    "artistry":          { "model": "opencode-go/deepseek-v4-flash" }
  }
  ```

  **Critères d'acceptation**:
  - `nix flake check` → OK
  - Config valide JSON

  **Commit**: OUI
  - Message: `omo: update model routing with DevPass + Go tiers`

---

## Vague de vérification finale

- [x] F1. `nix flake check` → OK
- [x] F2. Le fichier est du JSON valide et contient les nouveaux modèles

---

## Critères de succès

- [x] `oh-my-openagent.json` mis à jour
- [x] Agents premium sur DevPass (Kimi K3, GPT-5.6, GLM-5.2)
- [x] Agents légers sur OpenCode Go (deepseek-v4-flash)
- [x] `nix flake check` OK
