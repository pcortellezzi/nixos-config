# Plan: Paquet Codex CLI + LazyCodex dans my-nixpkgs

## TL;DR

> **Résumé**: Créer un paquet Nix pour l'agent de codage CLI Codex d'OpenAI (binaire pré-compilé) + module home-manager pour Configuration + LazyCodex harness
>
> **Livrables**:
> - `pkgs/codex/default.nix` dans my-nixpkgs (binaire musl statique)
> - `pkgs/codex/update.sh` pour mises à jour automatiques
> - `home/philippe/codex.nix` dans nixos-config (module home-manager)
> - Secret agenix `codex_api_key`
> - Workflow CI/CD `update-codex.yml` dans my-nixpkgs
>
> **Effort estimé**: Court (2-3 waves)
> **Exécution parallèle**: OUI — Wave 1 (my-nixpkgs) + Wave 2 (nixos-config) parallélisables
> **Chemin critique**: Tâche 1 → Tâche 3 → Tâche 5 → vérification

---

## Contexte

### Demande originale
Créer un paquet dans my-nixpkgs pour installer l'application Codex (agent de codage CLI OpenAI) + le harness LazyCodex.

### Résumé de l'interview
**Décisions clés**:
- **Asset**: `codex-package-x86_64-unknown-linux-musl.tar.gz` (binaire musl statique, pas de autoPatchelfHook)
- Aussi: `codex-code-mode-host-x86_64-unknown-linux-musl.tar.gz` (composant additionnel)
- **API key**: Via agenix (comme opencode), injectée dans un wrapper
- **LazyCodex**: Module home-manager avec activation script `npx lazycodex-ai install --no-tui --codex-autonomous`
- **Machines**: vvb + flip-cx5 (rôle desktop)
- **Mises à jour**: `update.sh` + workflow CI/CD dans my-nixpkgs
- **bwrap**: Utiliser `pkgs.bubblewrap` de nixpkgs (pas le bwrap du release)

### Résultats de recherche
- Le repo `github.com/openai/codex` contient l'agent de codage **CLI** d'OpenAI (Rust, musl), pas l'app ChatGPT desktop
- Chaque release contient 164+ assets (codex, bwrap, argument-comment-lint, etc.)
- nixpkgs upstream a déjà un package (build from source, complexe avec livekit-webrtc, v8, etc.)
- Notre approche binaire pré-compilé est bien plus simple
- LazyCodex installe plugins, agents, hooks dans `~/.codex/`

### Revue Metis
**Corrections appliquées**:
- ❌ ~~`codex-x86_64-unknown-linux-gnu.tar.gz`~~ → ✅ `codex-package-x86_64-unknown-linux-musl.tar.gz`
- ❌ ~~autoPatchelfHook + buildInputs~~ → ✅ Binaire musl 100% statique, aucun besoin
- ❌ ~~Simple binaire~~ → ✅ Multi-composants : codex + codex-code-mode-host + codex-resources
- ✅ Compression `.tar.gz` (pas besoin de zstd)
- ✅ LazyCodex = simple activation impérative (62 lignes de config, pas sur-ingéniérer)

---

## Objectifs

### Objectif principal
Permettre l'installation de Codex CLI + LazyCodex sur les machines desktop via NixOS/home-manager.

### Livrables concrets
- `/home/philippe/Projects/nixpkgs/pkgs/codex/default.nix`
- `/home/philippe/Projects/nixpkgs/pkgs/codex/update.sh`
- `/home/philippe/Projects/nixpkgs/.github/workflows/update-codex.yml`
- `/home/philippe/Projects/nixos-config/home/philippe/codex.nix`
- `/home/philippe/Projects/nixos-config/secrets/codex_api_key.age`
- Modifications dans `flake.nix` (my-nixpkgs + nixos-config)

### Doit avoir
- ✅ Téléchargement et extraction du binaire pré-compilé
- ✅ Wrapper avec injection OPENAI_API_KEY via agenix
- ✅ bubblewrap et ripgrep dans PATH pour le sandbox
- ✅ LazyCodex installé automatiquement (ou manuellement si trop complexe)
- ✅ Mise à jour automatique via CI/CD

### Ne doit PAS avoir (garde-fous)
- ❌ Pas d'`autoPatchelfHook` (binaire musl statique)
- ❌ Pas de build from source (on utilise les binaires du release)
- ❌ Pas de modification des fichiers `.codex/config.toml` en dehors de LazyCodex
- ❌ Pas de packaging complexe de oh-my-openagent en Nix
- ❌ Ne pas casser les paquets existants dans my-nixpkgs

---

## Stratégie de vérification

### Décision de test
- **Infrastructure existante**: OUI (nix flake check dans my-nixpkgs et nixos-config)
- **Tests automatisés**: Non (package binaire, pas de code à tester)
- **QA par agent**: 
  - `nix build .#codex` doit réussir dans my-nixpkgs
  - `nix flake check` doit passer
  - Vérifier que `codex --version` affiche la bonne version
  - Vérifier que le wrapper injecte bien OPENAI_API_KEY

---

## Stratégie d'exécution

```
Wave 1 (my-nixpkgs — tout en parallèle):
├── Tâche 1: Créer pkgs/codex/default.nix
├── Tâche 2: Enregistrer codex dans flake.nix (overlay + packages)
└── Tâche 3: Créer pkgs/codex/update.sh

Wave 2 (nixos-config — dépend de Wave 1):
├── Tâche 4: Créer secret agenix codex_api_key
├── Tâche 5: Créer home/philippe/codex.nix
└── Tâche 6: Ajouter codex.nix dans flake.nix (vvb + flip-cx5)

Wave 3 (CI/CD — dépend de Wave 1):
├── Tâche 7: Créer workflow update-codex.yml
└── Tâche 8: nix flake check + push

Chemin critique: Tâche 1 → Tâche 5 → vérification
Parallélisme max: 3 (Wave 1)
```

---

## TODOs

- [x] 1. Créer `pkgs/codex/default.nix` dans my-nixpkgs

  **Quoi faire**:
  - Créer le fichier `/home/philippe/Projects/nixpkgs/pkgs/codex/default.nix`
  - Télécharger `codex-package-x86_64-unknown-linux-musl.tar.gz` depuis les releases GitHub
  - Télécharger `codex-code-mode-host-x86_64-unknown-linux-musl.tar.gz` (composant additionnel)
  - Extraire les deux archives
  - Copier les binaires dans `$out/bin/`
  - Créer un wrapper `makeWrapper` qui ajoute `bubblewrap` et `ripgrep` dans PATH
  - Binaire musl statique → pas besoin d'autoPatchelfHook, pas de buildInputs C
  - Meta: description, homepage, license (asl20), platforms (x86_64-linux), mainProgram = "codex"
  - `dontStrip = true` (binaire pré-compilé)

  **Structure du tar.gz** (basé sur les analyses):
  ```
  codex-package-x86_64-unknown-linux-musl.tar.gz
  ├── codex                   # Binaire principal (298MB)
  ├── codex-code-mode-host    # Binaire mode code (46MB)
  └── codex-resources/        # Ressources additionnelles
  ```

  **Ne pas faire**:
  - ❌ Ne pas utiliser `autoPatchelfHook` (musl statique)
  - ❌ Ne pas ajouter de `buildInputs` C (pas besoin)

  **Profil d'agent recommandé**:
  - Catégorie: `quick`
  - Compétences: Aucune (package Nix simple)

  **Parallélisation**:
  - Peut run en parallèle: OUI
  - Groupe: Wave 1 (avec Tâches 2, 3)
  - Bloque: Tâches 5, 6, 7
  - Bloqué par: Rien

  **Références**:
  - `pkgs/jdk26/default.nix` — Pattern binaire pré-compilé dans my-nixpkgs
  - `https://github.com/openai/codex/releases/tag/rust-v0.144.5` — Release avec assets
  - `https://github.com/sadjow/codex-cli-nix` — Exemple de flake communautaire
  - Format URL des assets: `https://github.com/openai/codex/releases/download/rust-v${version}/codex-package-x86_64-unknown-linux-musl.tar.gz`

  **Critères d'acceptation**:
  - `nix build .#codex` dans my-nixpkgs → succès
  - `ls result/bin/codex` → fichier existe
  - `result/bin/codex --version` → affiche "0.144.5"
  - `nix flake check` dans my-nixpkgs → passe

  **Scénarios QA**:
  ```
  Scenario: Build du package codex
    Tool: bash
    Preconditions: Être dans /home/philippe/Projects/nixpkgs
    Steps:
      1. nix build .#codex --no-link 2>&1
    Expected Result: Build successful, pas d'erreur
    Evidence: .sisyphus/evidence/task-1-build.log

  Scenario: Vérification du binaire
    Tool: bash
    Preconditions: nix build .#codex réussi
    Steps:
      1. ls result/bin/codex
      2. result/bin/codex --version
    Expected Result: codex --version affiche la version 0.144.5
    Evidence: .sisyphus/evidence/task-1-version.log

  Scenario: Échec si mauvais hash
    Tool: bash
    Preconditions: hash incorrect dans default.nix
    Steps:
      1. nix build .#codex 2>&1 | head -20
    Expected Result: Erreur "hash mismatch" avec le bon hash suggéré
    Evidence: .sisyphus/evidence/task-1-hash-error.log
  ```

  **Commit**: OUI
  - Message: `codex: init at 0.144.5`
  - Fichiers: `pkgs/codex/default.nix`

- [x] 2. Enregistrer `codex` dans `flake.nix` de my-nixpkgs

  **Quoi faire**:
  - Ajouter dans `customPkgsOverlay` (dans le `let`):
    ```nix
    codex = callPackage ./pkgs/codex { };
    ```
  - Ajouter dans le set retourné par `customPkgsOverlay`:
    ```nix
    inherit codex;
    ```
  - Ajouter dans `packages.${system}`:
    ```nix
    inherit (pkgs) ... codex ...;
    ```
  - Ajouter dans le `default = pkgs.buildEnv { paths = ...; }`:
    ```nix
    codex
    ```

  **Ne pas faire**:
  - ❌ Ne pas casser l'ordre des overlays existants
  - ❌ Ne pas modifier d'autres entrées

  **Profil d'agent recommandé**:
  - Catégorie: `quick`
  - Compétences: Aucune

  **Parallélisation**:
  - Peut run en parallèle: OUI
  - Groupe: Wave 1 (avec Tâches 1, 3)

  **Références**:
  - `flake.nix:29-52` — Structure de `customPkgsOverlay`
  - `flake.nix:69-83` — Structure de `packages.${system}`

  **Critères d'acceptation**:
  - `nix flake check` → OK
  - `nix eval .#packages.x86_64-linux.codex` → renvoie une dérivation

  **Scénarios QA**:
  ```
  Scenario: Vérification enregistrement
    Tool: bash
    Preconditions: flake.nix modifié
    Steps:
      1. nix eval .#packages.x86_64-linux.codex.name
    Expected Result: Affiche "codex-0.144.5"
    Evidence: .sisyphus/evidence/task-2-registration.log
  ```

  **Commit**: OUI (avec tâche 1)
  - Message: `codex: init at 0.144.5`
  - Fichiers: `flake.nix`

- [x] 3. Créer `pkgs/codex/update.sh`

  **Quoi faire**:
  - Créer `/home/philippe/Projects/nixpkgs/pkgs/codex/update.sh`
  - Script bash qui:
    1. Fetch la dernière release via GitHub API
    2. Extrait la version du tag `rust-v{VERSION}`
    3. Compare avec la version dans `default.nix`
    4. Si différente, télécharge le tar.gz pour découvrir le nouveau hash
    5. `sed` pour remplacer `version` et `sha256` dans `default.nix`
    6. Fait la même chose pour `codex-code-mode-host`
  - Suivre le pattern de `pkgs/motivewave/update.sh`

  **Ne pas faire**:
  - ❌ Ne pas utiliser de tokens GitHub hard-coded (utiliser GITHUB_TOKEN env var)

  **Profil d'agent recommandé**:
  - Catégorie: `quick`
  - Compétences: Aucune

  **Parallélisation**:
  - Peut run en parallèle: OUI
  - Groupe: Wave 1 (avec Tâches 1, 2)

  **Références**:
  - `pkgs/motivewave/update.sh` — Pattern de script de mise à jour
  - `pkgs/krohnkite/update.sh` — Autre exemple avec API GitHub

  **Critères d'acceptation**:
  - `chmod +x pkgs/codex/update.sh && ./pkgs/codex/update.sh` → ne crash pas
  - Script utilise `nix-prefetch-url` pour découvrir les hash

  **Commit**: OUI (peut être mergé avec tâche 1-2)
  - Message: `codex: add update.sh`
  - Fichiers: `pkgs/codex/update.sh`

- [x] 4. Créer le secret agenix `codex_api_key`

  **Quoi faire**:
  - Chiffrer la clé API OpenAI avec agenix:
    ```bash
    agenix -e secrets/codex_api_key.age
    ```
  - Ajouter dans `secrets/secrets.nix` la déclaration du secret
  - Le fichier `.age` doit être déchiffrable par les clés host des machines desktop

  **Ne pas faire**:
  - ❌ Ne JAMAIS commiter la clé en clair
  - ❌ Ne pas oublier d'ajouter le secret dans `secrets.nix`

  **Profil d'agent recommandé**:
  - Catégorie: `quick`
  - Compétences: Aucune (nécessite interaction manuelle pour le chiffrement)

  **Parallélisation**:
  - Peut run en parallèle: OUI (avec Wave 1, mais nécessite la clé API manuellement)
  - Groupe: Wave 2
  - Bloqué par: Rien (mais nécessite d'avoir la clé API OpenAI)

  **Références**:
  - `secrets/secrets.nix` — Déclaration des secrets existants
  - `home/philippe/opencode.nix:32-34` — Pattern d'utilisation des secrets

  **Critères d'acceptation**:
  - `agenix -d secrets/codex_api_key.age` → affiche la clé correcte
  - Présent dans `secrets.nix`

- [x] 5. Créer `home/philippe/codex.nix` — Module home-manager pour Codex

  **Quoi faire**:
  - Créer `/home/philippe/Projects/nixos-config/home/philippe/codex.nix`
  - Structure similaire à `opencode.nix`:
    ```nix
    { config, pkgs, inputs, lib, ... }:
    let
      codexWrapped = pkgs.writeShellScriptBin "codex" ''
        export OPENAI_API_KEY=$(cat ${config.age.secrets.codex_api_key.path})
        exec ${pkgs.codex}/bin/codex "$@"
      '';
    in {
      age.secrets.codex_api_key = {
        file = ./secrets/codex_api_key.age;
      };

      home.packages = with pkgs; [
        codexWrapped
        nodejs        # Pour npx / lazycodex
        bubblewrap    # sandbox
        ripgrep       # grep amélioré pour codex
      ];

      # Activation script pour LazyCodex (une seule fois)
      home.activation.lazycodex = lib.hm.dag.entryAfter ["writeBoundary"] ''
        if [ ! -f "$HOME/.codex/config.toml" ]; then
          $VERBOSE_ECHO "Installing LazyCodex harness..."
          export OPENAI_API_KEY=$(cat ${config.age.secrets.codex_api_key.path})
          ${pkgs.nodejs}/bin/npx --yes --package oh-my-openagent@latest omo install --platform=codex --no-tui --codex-autonomous 2>/dev/null || $VERBOSE_ECHO "LazyCodex install deferred (run manually: npx lazycodex-ai install)"
        fi
      '';

      xdg.configFile = {
        # Config Codex si nécessaire
      };
    }
    ```

  - Option alternative: si l'activation script est trop complexe, juste documenter la commande
    et laisser l'utilisateur lancer `npx lazycodex-ai install` manuellement

  **Ne pas faire**:
  - ❌ Ne pas packager oh-my-openagent en Nix (trop complexe pour le bénéfice)
  - ❌ Ne pas rendre l'activation script bloquant (si npx échoue, le switch doit continuer)

  **Profil d'agent recommandé**:
  - Catégorie: `quick`
  - Compétences: Aucune

  **Parallélisation**:
  - Peut run en parallèle: NON
  - Groupe: Wave 2
  - Bloqué par: Tâche 1 (paquet codex doit exister)

  **Références**:
  - `home/philippe/opencode.nix` — Pattern complet du module home-manager
  - `home/philippe/desktop.nix` — Pattern d'installation de paquets

  **Critères d'acceptation**:
  - `nix flake check` dans nixos-config → OK
  - `nix build .#nixosConfigurations.vvb.config.home-manager.users.philippe.home.packages` → inclut codex

  **Scénarios QA**:
  ```
  Scenario: Vérification du module
    Tool: bash
    Preconditions: codex.nix créé, flake.nix modifié
    Steps:
      1. nix flake check 2>&1
    Expected Result: OK, pas d'erreur
    Evidence: .sisyphus/evidence/task-5-flake-check.log
  ```

  **Commit**: OUI
  - Message: `codex: add home-manager module with lazycodex activation`
  - Fichiers: `home/philippe/codex.nix`

- [x] 6. Ajouter `codex.nix` dans `flake.nix` de nixos-config

  **Quoi faire**:
  - Dans `flake.nix`, ajouter `./home/philippe/codex.nix` dans les `homeModules` de vvb et flip-cx5

  **Ne pas faire**:
  - ❌ Ne pas importer pour ser5 (serveur sans desktop)

  **Profil d'agent recommandé**:
  - Catégorie: `quick`
  - Compétences: Aucune

  **Parallélisation**:
  - Peut run en parallèle: NON (dépend de Tâche 5)
  - Groupe: Wave 2
  - Bloqué par: Tâche 5

  **Références**:
  - `flake.nix:99-116` — Structure des homeModules pour vvb et flip-cx5

  **Critères d'acceptation**:
  - `nix flake check` → OK

  **Commit**: OUI (avec tâche 5)
  - Message: `codex: add home-manager module with lazycodex activation`
  - Fichiers: `flake.nix`

- [ ] 7. Créer workflow `update-codex.yml` dans my-nixpkgs

  **Quoi faire**:
  - Créer `.github/workflows/update-codex.yml` dans my-nixpkgs
  - Similaire à `update-motivewave.yml`
  - Déclencheur: daily à 08:00 + manuel (workflow_dispatch)
  - Steps:
    1. `git checkout -B update/codex`
    2. `cd pkgs/codex && ./update.sh`
    3. Si des changements détectés: commit + push + PR
  - Doit détecter les nouvelles versions de codex automatiquement

  **Ne pas faire**:
  - ❌ Ne pas dupliquer la logique de `update.sh` dans le workflow YAML

  **Profil d'agent recommandé**:
  - Catégorie: `quick`
  - Compétences: Aucune

  **Parallélisation**:
  - Peut run en parallèle: OUI
  - Groupe: Wave 3 (indépendant mais après Wave 1 pour update.sh)

  **Références**:
  - `.github/workflows/update-motivewave.yml` — Pattern de workflow de mise à jour

  **Critères d'acceptation**:
  - Workflow visible dans GitHub Actions
  - `act -j update-codex --dry-run` → steps valides

  **Commit**: OUI (peut être séparé)
  - Message: `ci: add auto-update workflow for codex`
  - Fichiers: `.github/workflows/update-codex.yml`

---

## Vague de vérification finale

- [ ] F1. **Vérification plan** — `oracle`
  Vérifier que tous les "Doit avoir" sont implémentés :
  - `nix build .#codex` dans my-nixpkgs → OK
  - `nix flake check` dans my-nixpkgs → OK
  - `nix flake check` dans nixos-config → OK
  - Secret agenix présent et déchiffrable
  - update.sh exécutable
  - Workflow CI/CD présent

- [ ] F2. **Vérification qualité** — `unspecified-high`
  - Relire les fichiers créés pour détecter les problèmes
  - Vérifier que les hash sont corrects
  - Vérifier que `meta` est complet
  - Vérifier l'absence d'AI slop

---

## Stratégie de commit

- **Wave 1** (commits dans my-nixpkgs):
  1. `codex: init at 0.144.5` — pkgs/codex/default.nix + flake.nix
  2. `codex: add update.sh` — pkgs/codex/update.sh
  3. `ci: add auto-update workflow for codex` — .github/workflows/update-codex.yml

- **Wave 2** (commits dans nixos-config):
  4. `codex: add home-manager module with lazycodex activation` — home/philippe/codex.nix + flake.nix
  5. `codex: add agenix secret` — secrets/codex_api_key.age

---

## Critères de succès

- [ ] `nix build .#codex` dans my-nixpkgs → OK
- [ ] `nix flake check` dans my-nixpkgs → OK
- [ ] `nix flake check` dans nixos-config → OK
- [ ] `codex --version` après déploiement → version correcte
- [ ] LazyCodex installé sur vvb et flip-cx5
- [ ] Mise à jour automatique via CI/CD fonctionnelle
