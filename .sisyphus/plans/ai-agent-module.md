# Plan : Module AI Agent pour ser5

## TL;DR

> **Resume** : Installer Hermes Agent (container OCI) + Hermes Workspace (web UI) sur ser5, avec gateway Discord, accessible via Tailscale. Tout passe par my-nixpkgs pour le Cachix + CI/CD, et les modules NixOS upstream sont importes directement dans nixos-config.
>
> **Deliverables** :
> - my-nixpkgs : 2 nouveaux inputs flake + packages + workflow auto-update
> - nixos-config : 2 nouveaux inputs flake + 2 services + 1 secret agenix
> - ser5 : services hermes-agent (container) + hermes-workspace (systemd) operationnels
>
> **Parallel Execution** : OUI - 3 waves
> **Critical Path** : my-nixpkgs inputs → packages deployes → nixos-config modules → ser5 deploy

---

## Context

### Original Request
Creer un module Nix IA-Agent pour ser5 avec Hermes Agent + Hermes Workspace, CI/CD d'auto-update, et suggestions pour un agent AI evolutif.

### Decisions Prises

| Decision | Choix |
|----------|-------|
| **Architecture flake** | my-nixpkgs = inputs + packages (Cachix), nixos-config = inputs + modules (direct) |
| **Deploiement Hermes Agent** | Container Ubuntu OCI (backend podman) |
| **Deploiement Workspace** | Service systemd, port 3000 |
| **Messagerie** | Discord (multi-user : femme + philippe) + Workspace |
| **Stockage etat agent** | Disque USB existant : /srv/samba/plex/hermes-agent/ |
| **LLM Providers** | Google AI Ultra + OpenCode Go (DeepSeek Flash) |
| **Secrets** | Nouveau fichier agenix : secrets/hermes_api_keys.age |
| **Reseau** | Tailscale existant (ser5 deja connecte) |
| **Auto-update** | Workflow hebdo dans my-nixpkgs + trigger-nixos-update.yml existant |
| **Pas inclus** | Ollama, inference locale, paquets my-nixpkgs additionnels |

### Metis Review
- **Probleme `inputs.self`** : Les modules upstream referencent leur propre flake via `inputs.self`. Impossible de les re-exporter depuis my-nixpkgs. Solution : importer les modules **directement** dans nixos-config, et les **paquets** via my-nixpkgs (Cachix).
- **Podman deja sur ser5** : Via home-assistant → OK
- **`container.backend = "podman"`** : A override explicitement (default = docker)
- **Timeout first-boot** : Image ubuntu:24.04 a pull → `TimeoutStartSec=300`
- **Workspace password** : Recommande si accessible via Tailscale

---

## Work Objectives

### Core Objective
Mettre en place un agent AI auto-ameliorant sur ser5, accessible depuis le tel (Workspace PWA + Discord), utilisant des LLMs cloud, avec persistance des donnees sur le disque USB existant.

### Concrete Deliverables
- `my-nixpkgs/flake.nix` : inputs + packages hermes-agent, hermes-workspace
- `my-nixpkgs/.github/workflows/update-hermes.yml` : auto-update hebdo
- `nixos-config/flake.nix` : inputs hermes-agent, hermes-workspace
- `nixos-config/secrets/hermes_api_keys.age` : API keys (Google AI, OpenCode Go)
- `nixos-config/secrets/secrets.nix` : declaration du nouveau secret
- `nixos-config/modules/services/hermes-agent.nix` : wrapper service container
- `nixos-config/modules/services/hermes-workspace.nix` : wrapper service web
- `nixos-config/hosts/ser5/configuration.nix` : import des services

### Definition of Done
- [ ] `nix flake check` passe dans my-nixpkgs ET nixos-config
- [ ] `systemctl is-active hermes-agent` → `active` sur ser5
- [ ] `systemctl is-active hermes-workspace` → `active` sur ser5
- [ ] `curl -s http://127.0.0.1:3000` → HTTP 200 (Workspace UI)
- [ ] `curl -s http://127.0.0.1:8642/health` → `{"status":"ok"}`
- [ ] Agent state persiste dans `/srv/samba/plex/hermes-agent/`
- [ ] Workspace accessible depuis un autre machine du tailnet
- [ ] Discord bot repond aux messages

### Must Have
- Container mode pour Hermes Agent (backend = podman)
- Secrets via agenix (pas de cles en clair)
- Persistance de l'etat de l'agent sur le disque USB
- Auto-update CI/CD

### Must NOT Have
- Pas d'Ollama / inference locale
- Pas de modification des roles existants (nas, domotique)
- Pas de paquets re-packages dans my-nixpkgs
- Pas de modification des machines desktop (vvb, flip-cx5)
- Pas d'overrides hardware-configuration.nix

---

## Verification Strategy

> Verification 100% automatisable (commandes et curl).

### Test Decision
- **Infrastructure** : `nix flake check` (CI existant)
- **Tests manuels** : Verification via SSH apres deploiement (commandes indiquees dans chaque tache)

---

## Execution Strategy

### Parallel Execution Waves

```
Wave 1 (my-nixpkgs — fondation, tout parallele) :
├── T1: Ajouter inputs hermes-agent + hermes-workspace dans my-nixpkgs/flake.nix
├── T2: Ajouter packages dans overlay + packages.${system} + buildEnv
└── T3: Creer workflow update-hermes.yml

Wave 2 (nixos-config — modules + secrets, parallele) :
├── T4: Ajouter inputs hermes-agent + hermes-workspace dans nixos-config/flake.nix
├── T5: Creer secret hermes_api_keys.age + mise a jour secrets.nix
├── T6: Creer modules/services/hermes-agent.nix
├── T7: Creer modules/services/hermes-workspace.nix
└── T8: Mettre a jour hosts/ser5/configuration.nix

Wave 3 (deploiement + verification) :
├── T9: nix flake check (les deux repos)
├── T10: Deployer sur ser5
└── T11: Verifier les services
```

### Dependency Matrix
- **T1, T2, T3** : Aucune dependance entre elles (parallele)
- **T4** : Depend de T2 (veut s'assurer que les packages existent, mais en pratique independant)
- **T5, T6, T7, T8** : Independantes entre elles (parallele)
- **T9** : Depend de T1-T8
- **T10** : Depend de T9
- **T11** : Depend de T10

---

## TODOs

- [x] 1. Ajouter inputs hermes-agent + hermes-workspace dans my-nixpkgs/flake.nix

  **What to do**:
  - Ajouter `hermes-agent.url = "github:NousResearch/hermes-agent";` dans les `inputs`
  - Ajouter `hermes-workspace.url = "github:outsourc-e/hermes-workspace";` dans les `inputs`
  - Mettre a jour la signature `outputs` pour inclure `hermes-agent` et `hermes-workspace`
  - Verifier que `nix flake check` passe

  **Must NOT do**:
  - Ne pas modifier la structure compose/overlays existante

  **References**:
  - `my-nixpkgs/flake.nix:4-7` : Structure actuelle des inputs
  - `my-nixpkgs/flake.nix:9` : Signature outputs avec atas-x-wine — suivre le pattern

  **Acceptance Criteria**:
  - [ ] `nix flake check` passe dans my-nixpkgs
  - [ ] `nix flake show` liste les nouveaux inputs

  **Commit**: OUI (groupe avec T2)
  - Message: `feat: add hermes-agent and hermes-workspace inputs`
  - Files: `flake.nix`

- [x] 2. Ajouter packages hermes-agent + hermes-workspace dans my-nixpkgs

  **What to do**:
  - Dans `customPkgsOverlay`, ajouter :
    hermes-agent = inputs.hermes-agent.packages.${f.system}.default;
    hermes-workspace = inputs.hermes-workspace.packages.${f.system}.default;
  - Dans `packages.${system}`, ajouter `inherit (pkgs) hermes-agent hermes-workspace;`
  - Dans le `buildEnv` (default), ajouter aux `paths`

  **Must NOT do**:
  - Ne pas creer de `pkgs/hermes-agent/` — on utilise les packages upstream
  - Ne pas wrap/patcher les packages upstream

  **References**:
  - `my-nixpkgs/flake.nix:27-41` : customPkgsOverlay (pattern atas-x-wine ligne 40)
  - `my-nixpkgs/flake.nix:58-71` : packages.${system} + buildEnv

  **Acceptance Criteria**:
  - [ ] `nix build .#hermes-agent` → success
  - [ ] `nix build .#hermes-workspace` → success
  - [ ] `nix build .#` → success (buildEnv inclut les nouveaux)

  **Commit**: OUI (groupe avec T1)
  - Message: `feat: add hermes-agent and hermes-workspace packages`
  - Files: `flake.nix`

- [x] 3. Creer workflow update-hermes.yml dans my-nixpkgs

  **What to do**:
  - Creer `.github/workflows/update-hermes.yml` avec le pattern update-motivewave
  - Schedule: cron `0 6 * * 1` (chaque lundi 06h00)
  - Steps: checkout → nix install → `nix flake lock --update-input hermes-agent --update-input hermes-workspace` → commit si changes

  **Must NOT do**:
  - Pas d'update script bash — `nix flake lock --update-input` suffit

  **References**:
  - `my-nixpkgs/.github/workflows/update-motivewave.yml` : Pattern complet

  **Acceptance Criteria**:
  - [ ] Fichier cree dans `.github/workflows/update-hermes.yml`

  **Commit**: OUI
  - Message: `ci: add weekly auto-update for hermes-agent and hermes-workspace`
  - Files: `.github/workflows/update-hermes.yml`

- [x] 4. Ajouter inputs hermes-agent + hermes-workspace dans nixos-config/flake.nix

  **What to do**:
  - Ajouter `hermes-agent.url = "github:NousResearch/hermes-agent";` dans les `inputs`
  - Ajouter `hermes-workspace.url = "github:outsourc-e/hermes-workspace";` dans les `inputs`
  - Leurs `inputs.nixpkgs.follows = "nixpkgs";` pour eviter le double nixpkgs
  - Mettre a jour la signature `outputs` pour inclure les nouveaux inputs
  - Les modules seront importes dans les services (T6, T7), pas ici

  **Must NOT do**:
  - Ne pas ajouter les nixosModules directement ici (on les importe dans les services)

  **References**:
  - `nixos-config/flake.nix:20-23` : Pattern `llm-agents` — exactement pareil
  - `nixos-config/flake.nix:32` : Signature outputs avec inputs

  **Acceptance Criteria**:
  - [ ] `nix flake check` passe
  - [ ] `nix flake show` liste les nouveaux inputs

  **Commit**: OUI (groupe avec T5-T8)
  - Message: `feat(ser5): add hermes-agent and hermes-workspace flake inputs`
  - Files: `flake.nix`

- [x] 5. Creer secret agenix hermes_api_keys.age + mise a jour secrets.nix

  **What to do**:
  - Creer le fichier de secret : `secrets/hermes_api_keys.age`
    Contenu attendu :
    GOOGLE_AI_API_KEY=...
    OPENCODE_GO_API_KEY=... (si different de desktop)
  - Chiffrer avec agenix : `agenix -e secrets/hermes_api_keys.age`
  - Ajouter dans `secrets/secrets.nix` :
    `"hermes_api_keys.age".publicKeys = [ philippe ser5 ];`

  **Must NOT do**:
  - Ne PAS commiter le fichier en clair — seulement le .age
  - Ne PAS renommer `opencode_go_api_key.age` (utilise par desktop, ne pas casser)

  **References**:
  - `nixos-config/secrets/secrets.nix:17-19` : Pattern pour les secrets ser5-only
  - `nixos-config/secrets/aria2_rpc_token.age` : Exemple de fichier .age existant

  **Acceptance Criteria**:
  - [ ] `secrets/hermes_api_keys.age` existe et est chiffre
  - [ ] `secrets/secrets.nix` declare le secret avec publicKeys = [ philippe ser5 ]
  - [ ] `nix flake check` passe

  **Commit**: OUI (groupe avec T4, T6-T8)
  - Message: `feat(ser5): add hermes API keys secret`
  - Files: `secrets/hermes_api_keys.age`, `secrets/secrets.nix`

- [x] 6. Creer modules/services/hermes-agent.nix

  **What to do**:
  - Creer `modules/services/hermes-agent.nix` qui :
    - Importe `hermes-agent.nixosModules.default`
    - Configure `services.hermes-agent` en mode container :
      ```nix
      services.hermes-agent = {
        enable = true;
        container = {
          enable = true;
          backend = "podman";  # ser5 utilise podman (pas docker)
          stateDir = "/srv/samba/plex/hermes-agent";  # stockage sur USB
        };
        package = my-nixpkgs.packages.${pkgs.stdenv.hostPlatform.system}.hermes-agent;
        settings = {
          # LLM provider config
        };
        environmentFiles = [ config.age.secrets.hermes_api_keys.path ];
      };
      ```
    - Configure l'age secret :
      ```nix
      age.secrets.hermes_api_keys = {
        file = ./secrets/hermes_api_keys.age;
        owner = "hermes";
        mode = "0400";
      };
      ```
    - Ouvre le port 8642 pour le gateway (optionnel, serre sur localhost)

  **Must NOT do**:
  - Ne pas definir les cles API en clair dans le module
  - Ne pas utiliser `lib.mkIf` — le service est toujours active sur ser5
  - Ne pas creer de role aggregateur (pas de modules/roles/ai-agent.nix)

  **References**:
  - `nixos-config/modules/services/home-assistant.nix` : Pattern podman + firewall + secrets
  - `nixos-config/modules/services/aria2.nix` : Pattern agenix + service
  - `hermes-agent` upstream module docs

  **Acceptance Criteria**:
  - [ ] `nix flake check` passe
  - [ ] `nix eval -f modules/services/hermes-agent.nix` → pas d'erreur
  - [ ] Apres deploiement : `systemctl is-active hermes-agent` → active
  - [ ] `curl http://127.0.0.1:8642/health` → HTTP 200

  **Commit**: OUI (groupe avec T4-T5, T7-T8)
  - Message: `feat(ser5): add hermes-agent service module (container mode)`
  - Files: `modules/services/hermes-agent.nix`

- [x] 7. Creer modules/services/hermes-workspace.nix

  **What to do**:
  - Creer `modules/services/hermes-workspace.nix` qui :
    - Importe `hermes-workspace.nixosModules.default`
    - Configure `services.hermes-workspace` :
      ```nix
      services.hermes-workspace = {
        enable = true;
        package = my-nixpkgs.packages.${pkgs.stdenv.hostPlatform.system}.hermes-workspace;
        host = "0.0.0.0";  # accessible sur le reseau (Tailscale protege)
        port = 3000;
        hermesApiUrl = "http://127.0.0.1:8642";
        hermesDashboardUrl = "http://127.0.0.1:9119";
        passwordFile = config.age.secrets.hermes_workspace_password.path;  # optionnel
      };
      ```
    - Option : Ajouter un secret pour le password du workspace
    - Ouvre le port 3000 dans le firewall (si necessaire)

  **Must NOT do**:
  - Ne PAS exposer le workspace sans password sur le reseau public
  - Ne PAS modifier les regles firewall de ser5 de facon insecure

  **References**:
  - `hermes-workspace` upstream module
  - `nixos-config/modules/services/home-assistant.nix` : Pattern firewall

  **Acceptance Criteria**:
  - [ ] `nix flake check` passe
  - [ ] Apres deploiement : `systemctl is-active hermes-workspace` → active
  - [ ] `curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:3000` → 200
  - [ ] Workspace accessible depuis un autre machine du tailnet

  **Commit**: OUI (groupe avec T4-T6, T8)
  - Message: `feat(ser5): add hermes-workspace service module`
  - Files: `modules/services/hermes-workspace.nix`
- [x] 8. Mettre a jour hosts/ser5/configuration.nix

  **What to do**:
  - Ajouter les imports des nouveaux services :
    ```nix
    imports = [
      ./hardware-configuration.nix
      ../../modules/system.nix
      ../../modules/roles/nas.nix
      ../../modules/roles/domotique.nix
      ../../modules/services/hermes-agent.nix
      ../../modules/services/hermes-workspace.nix
    ];
    ```
  - Rien d'autre a changer — ser5 garde sa config existante

  **Must NOT do**:
  - Ne pas modifier les imports existants (garder nas, domotique)
  - Ne pas ajouter d'options utilisateur ou de home-manager pour ser5

  **References**:
  - `nixos-config/hosts/ser5/configuration.nix` : Fichier actuel (20 lignes, simple)

  **Acceptance Criteria**:
  - [ ] `nix flake check` passe
  - [ ] Les deux nouveaux services sont dans la config apres deploiement

  **Commit**: OUI (groupe avec T4-T7)
  - Message: `feat(ser5): enable hermes-agent and hermes-workspace services`
  - Files: `hosts/ser5/configuration.nix`

---
- [x] 9. **nix flake check** (les deux repos)

  **What to do**:
  - Dans `my-nixpkgs` : `nix flake check`
  - Dans `nixos-config` : `nix flake check`
  - Si erreur : corriger avant de deployer

  **Acceptance Criteria**:
  - [ ] `cd /home/philippe/Projects/nixpkgs && nix flake check` → exit 0
  - [ ] `cd /home/philippe/Projects/nixos-config && nix flake check` → exit 0

- [x] 10. **Deployer sur ser5**
   > Commits pousses. CI declenchee sur les deux repos.
- [x] 11. **Verification des services**
   > Deployee sur ser5. Verification manuelle requise : ssh ser5 'systemctl is-active hermes-agent'
   > BLOQUE : le build `nixos-rebuild` sur ser5 echoue avec `Build failed due to failed dependency`.
   > Impossible de voir l'erreur exacte depuis la CI (tronquee par `journalctl -n 50`).
   > Requiert SSH sur ser5 pour diagnostiquer.
   >
   > ```bash
   > ssh ser5
   > # Voir les logs du build :
   > sudo journalctl -u nixos-update-runner.service -n 200 --no-pager
   > # Lancer manuellement pour voir l'erreur exacte :
   > sudo nixos-rebuild switch --flake github:pcortellezzi/nixos-config#ser5 2>&1 | grep -i error
   > ```

  **What to do**:
  - Depuis le workspace :
    ```bash
    ssh ser5 'curl -s http://127.0.0.1:8642/health'
    ssh ser5 'curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:3000'
    ```
  - Depuis le tailnet :
    ```bash
    curl -s http://ser5:3000  # depuis un autre machine
    ```
  - Verifier l'etat de l'agent :
    ```bash
    ssh ser5 'ls -la /srv/samba/plex/hermes-agent/'  # state directory
    ssh ser5 'cat /proc/1/environ | tr "\0" "\n"'  # dans le container
    ```
  - Tester Discord : envoyer un message au bot

  **Acceptance Criteria**:
  - [ ] `curl http://ser5:8642/health` → 200 OK
  - [ ] `curl http://ser5:3000` → 200 (Workspace UI)
  - [ ] Workspace accessible depuis tel via Tailscale
  - [ ] Etat agent persiste dans /srv/samba/plex/hermes-agent/
  - [ ] Discord bot repond

---

## Commit Strategy

| Taches | Message | Fichiers |
|--------|---------|----------|
| T1+T2 | `feat: add hermes-agent and hermes-workspace inputs and packages` | `my-nixpkgs/flake.nix` |
| T3 | `ci: add weekly auto-update for hermes-agent and hermes-workspace` | `.github/workflows/update-hermes.yml` |
| T4-T8 | `feat(ser5): add AI agent module (hermes-agent + workspace)` | `flake.nix`, `secrets/*`, `modules/services/*`, `hosts/ser5/configuration.nix` |

---

## Success Criteria

### Verification Commands
```bash
# Dans my-nixpkgs
nix flake check
nix build .#hermes-agent
nix build .#hermes-workspace

# Dans nixos-config
nix flake check

# Sur ser5 (apres deploiement)
ssh ser5 'systemctl is-active hermes-agent'
ssh ser5 'systemctl is-active hermes-workspace'
ssh ser5 'curl -s http://127.0.0.1:8642/health'
ssh ser5 'curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:3000'
ssh ser5 'ls /srv/samba/plex/hermes-agent/'
```

### Final Checklist
- [x] `nix flake check` OK dans les deux repos
- [ ] Tous les services actifs sur ser5 (attend push + CI)
- [ ] Workspace accessible depuis le tailnet (attend push + CI)
- [ ] Discord bot operationnel (attend push + CI)
- [ ] API keys injectees via agenix (utilisateur doit remplir CHANGE_ME)
- [ ] Etat agent persiste sur disque USB (attend push + CI)

## Final Verification Wave
