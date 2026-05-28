# AGENTS.md — nixos-config & my-nixpkgs

> Guide de référence pour les agents IA travaillant sur la configuration NixOS et les paquets personnalisés de Philippe. Les deux dépôts sont liés — tout changement dans l'un peut impacter l'autre.

---

## Vue d'ensemble

```
┌────────────────────────────────────────────────────────────┐
│  my-nixpkgs: /home/philippe/Projects/nixpkgs              │
│  github:pcortellezzi/nixpkgs                              │
│                                                            │
│  Rôle : paquets custom + overlays de patching             │
│  CI : push main → build → Cachix → lock update config     │
└───────────────────────────┬────────────────────────────────┘
                            │ flake input + overlay
                            ▼
┌────────────────────────────────────────────────────────────┐
│  nixos-config: /home/philippe/Projects/nixos-config       │
│  github:pcortellezzi/nixos-config                         │
│                                                            │
│  Rôle : configuration déclarative de 3 machines           │
│  CI : push main → Tailscale SSH → nixos-rebuild switch    │
└────────────────────────────────────────────────────────────┘
```

### 3 machines gérées

| Machine | Type | Rôles | GPU |
|---------|------|-------|-----|
| `ser5` | Serveur (AMD) | nas, domotique | — |
| `vvb` | Desktop principal | desktop (KDE Plasma 6) | AMD iGPU + NVIDIA dGPU |
| `flip-cx5` | Laptop | desktop (KDE Plasma 6) | Intel intégré |

---

## Architecture de nixos-config

### Le point d'entrée : `mkHost` dans `flake.nix`

Toute machine est créée via **une seule fonction** (`mkHost`, lignes 60-101 de `flake.nix`). C'est le point unique où enregistrer un nouvel hôte :

```nix
nixosConfigurations = {
  nouvel-host = mkHost {
    hostPath = ./hosts/nouvel-host/configuration.nix;
    homeModules = [
      ./home/philippe/common.nix     # toujours
      ./home/philippe/desktop.nix    # si desktop
    ];
  };
};
```

`mkHost` injecte automatiquement :
- `specialArgs = { inputs; stateVersion; }` → dispo dans tous les sous-modules
- Overlay my-nixpkgs (`nixpkgs.overlays = [ my-nixpkgs.overlays.default ]`)
- `allowUnfree = true`
- Modules système obligatoires : auto-update, manual-update
- Intégration agenix, home-manager
- Clé SSH utilisateur déployée via agenix

### Composition modulaire (ordre d'imports)

```
flake.nix (mkHost)
  ├── modules/system/auto-update.nix      # toujours
  ├── modules/system/manual-update.nix    # toujours
  ├── hostPath → hosts/<name>/configuration.nix
  │     ├── hardware-configuration.nix    # auto-généré, NE PAS MODIFIER
  │     └── ../../modules/system.nix      # base partagée
  │           ├── services/openssh.nix
  │           ├── services/avahi.nix
  │           ├── services/resolved.nix
  │           ├── common/locale.nix       # fr_FR, America/Cayenne
  │           ├── common/wifi-networks.nix
  │           └── common/deploy-user.nix
  │     └── ../../modules/roles/*.nix     # agrégateurs de services
  │           └── services/*.nix          # services individuels
  ├── agenix.nixosModules.default
  └── home-manager.nixosModules.home-manager
        └── user philippe
              ├── common.nix
              ├── desktop.nix (si desktop)
              └── opencode.nix (si desktop)
```

### Rôles et services

| Fichier | Contenu |
|---------|---------|
| `modules/system.nix` | Boot systemd-boot, kernel zen, NetworkManager, cachix, GitHub token, known_hosts |
| `modules/roles/desktop.nix` | Agrège : plymouth, bluetooth, displaylink, solaar, pipewire, printing, tailscale, SDDM, Plasma |
| `modules/roles/nas.nix` | Agrège : tailscale, samba, plex, aria2 |
| `modules/roles/domotique.nix` | Home Assistant |
| `modules/roles/builder.nix` | Clé de signature Nix (défini mais non importé actuellement) |

### Home-manager (`home/philippe/`)

| Module | Contenu |
|--------|---------|
| `common.nix` | SSH config (github.com), bash, direnv, clé publique |
| `desktop.nix` | Apps desktop : motivewave, Chrome, TradingView, Obsidian, Zoom, OBS, Wine, etc. |
| `opencode.nix` | OpenCode AI dev agent : API key, modèles voix (whisper+piper), TUI config |
| `plasma.nix` | KDE Plasma 6 : barre, raccourcis, thème Darkly, krohnkite, kwin-better-blur |

### Secrets avec agenix

- **9 fichiers `.age`** dans `secrets/`
- `secrets/secrets.nix` définit quelle clé publique peut déchiffrer quel secret
- Système utilise `/etc/ssh/ssh_host_ed25519_key`, home-manager utilise `~/.ssh/id_ed25519`
- **Ne jamais créer de secrets sans passer par agenix**

### Conventions à respecter

- **`hardware-configuration.nix` est auto-généré** — ne pas modifier manuellement
- **Les rôles sont des agrégateurs** — ils `import`ent des services, ne contiennent pas de config inline
- **Les services sont atomiques** — un fichier = un service, self-contained
- **Pas de config dupliquée** — si deux machines partagent un service, le mettre dans `system.nix` ou un rôle
- **`lib.mkIf`** pour les options togglables (ex: `config.my.auto-update.enable`)
- **`specialArgs`** pour passer `inputs` et `stateVersion` aux sous-modules
- **Pas de `rec`** dans `mkDerivation` sauf si nécessaire pour `version` référencée dans `src.url`

---

## Architecture de my-nixpkgs

**Emplacement :** `/home/philippe/Projects/nixpkgs`  
**Remote :** `github:pcortellezzi/nixpkgs`  
**Consommé par nixos-config via :** `nixpkgs.overlays = [ my-nixpkgs.overlays.default ]`

### Paquets

| Paquet | Type | Source |
|--------|------|--------|
| `jdk26` | Adoptium Temurin JDK 26 | GitHub releases (binaires précompilés) |
| `motivewave` | Plateforme de trading | .deb depuis motivewave.com |
| `tealstreet` | Terminal crypto trading | AppImage GitHub |
| `hyprspace` | Plugin Hyprland | GitHub (fork pcortellezzi) |
| `opencode-voice-models` | Modèles voix whisper+piper | HuggingFace (pré-téléchargés) |
| `krohnkite` | Tiling KWin | Codeberg .kwinscript |
| `plasma-panel-colorizer` | Thème barre Plasma 6 | GitHub releases |
| `plasma-window-title-applet` | Titre fenêtre Plasma 6 | GitHub (commit pin) |

### Overlays (composition empilée)

L'overlay `default` est composé de 4 couches appliquées séquentiellement via une fonction `compose` (foldl) :

1. `hyprland.overlays.hyprland-packages` — paquets Hyprland upstream (hyprland, aquamarine)
2. `aquamarine-evdi.nix` — patch C++ pour compatibilité EVDI/DisplayLink
3. `displaylink.nix` — override l'URL source du driver DisplayLink
4. `customPkgsOverlay` — injections des 8 paquets locaux + force hyprland/aquamarine patchés

**Ordre crucial :** chaque overlay construit sur le précédent. Ne pas réordonner sans comprendre les dépendances.

### CI/CD de my-nixpkgs

| Workflow | Déclencheur | Action |
|----------|-------------|--------|
| `nix-cache.yml` | push main (hors `.github/`) | `nix build .#` → push to `pcortellezzi.cachix.org` |
| `trigger-nixos-update.yml` | nix-cache success | Clone nixos-config → `nix flake lock --update-input my-nixpkgs` → commit+push |
| `update-motivewave.yml` | daily 10:00 + manuel | Vérifie nouvelle version MotiveWave → met à jour hash+version |
| `update-displaylink.yml` | daily 09:00 + manuel | Sync displaylink overlay depuis nixpkgs upstream |

---

## CI/CD de nixos-config

### `deploy.yml` — Déploiement sur push main

Déclenché sur push vers `main` quand `flake.nix`, `flake.lock`, `home/**`, `hosts/**`, `lib/**`, `modules/**`, ou `secrets/**` changent. Dispatch manuel avec sélecteur de host.

**Fonctionnement : ne build PAS dans CI.** Le runner GitHub :
1. `nix flake check` (validation seulement)
2. Connexion Tailscale (OAuth)
3. Installe clé SSH de déploiement
4. Résout host keys via `nix eval -f lib/ssh-host-keys.nix`
5. Vérifie disponibilité (netcat port 22)
6. **`ssh <host> "sudo systemctl start --no-block nixos-update-runner.service"`**
7. Poll `systemctl is-active` (max 600s)
8. En cas d'échec → dump `journalctl`

### `update-flake-inputs.yml` — Mise à jour mensuelle

Tous les 1ers du mois + manuel : `nix flake update` → commit `flake.lock` → push.

### Secrets GitHub Actions requis

| Secret | Usage |
|--------|-------|
| `PAT` | Accès GitHub pour private flake inputs |
| `TS_OAUTH_CLIENT_ID` / `TS_OAUTH_CLIENT_SECRET` | Tailscale OAuth |
| `DEPLOY_KEY` | Clé SSH pour connexion aux hôtes |

---

## Guides par use case

### Ajouter une nouvelle machine

1. Générer `hardware-configuration.nix` sur la machine cible :
   ```bash
   nixos-generate-config --root /mnt  # ou --root / sur une machine existante
   ```
2. Copier dans `hosts/<nom>/hardware-configuration.nix`
3. Créer `hosts/<nom>/configuration.nix` :
   ```nix
   { ... }:
   {
     imports = [
       ./hardware-configuration.nix
       ../../modules/system.nix
       ../../modules/roles/desktop.nix  # ou nas, etc.
     ];
     networking.hostName = "<nom>";
     users.users.philippe = {
       isNormalUser = true;
       description = "Philippe CORTELLEZZI";
       extraGroups = [ "networkmanager" "wheel" ];
     };
   }
   ```
4. Ajouter dans `flake.nix` → `nixosConfigurations` avec `mkHost`
5. Clé SSH host dans `lib/ssh-host-keys.nix`
6. Générer secrets host dans `secrets/secrets.nix`
7. Ajouter dans la matrice CI de `.github/workflows/deploy.yml`
8. Ajouter dans les options `workflow_dispatch` de `deploy.yml`

### Ajouter un nouveau service

1. Créer `modules/services/<nom>.nix` — module autonome
2. Soit l'importer dans `modules/system.nix` (toutes les machines), soit dans un rôle spécifique, soit directement dans le host
3. Si le service a besoin de secrets → agenix dans `secrets/secrets.nix`

### Ajouter un nouveau rôle

1. Créer `modules/roles/<nom>.nix` — qui importe les services nécessaires
2. Importer ce rôle dans le(s) host(s) concerné(s)

### Ajouter un nouveau paquet dans my-nixpkgs

1. Créer `pkgs/<nom>/default.nix` — utilisant `callPackage`
2. Dans `flake.nix` → `customPkgsOverlay` (lignes 27-50) :
   - Ajouter le `callPackage` dans la `let`
   - Ajouter le paquet dans le set retourné
3. Dans `flake.nix` → `outputs.packages.${system}` :
   - Ajouter `inherit (pkgs) <nom>;`
   - Ajouter dans `pkgs.buildEnv` (pour le build CI global)
4. Builder localement : `nix build .#<nom>`
5. Builder tout : `nix build .#`

### Mettre à jour les inputs flake

```bash
# Dans nixos-config
nix flake update              # tout
nix flake lock --update-input my-nixpkgs  # un seul input
```

**Attention :** `nix flake update` est déclenché automatiquement chaque mois par la CI. Un commit manuel n'est nécessaire que pour une mise à jour urgente.

### Debugger un déploiement qui échoue

1. Vérifier les logs GitHub Actions du workflow `deploy.yml`
2. Si le runner n'atteint pas la machine → vérifier Tailscale (ACL tags `gh-nixos-deploy-runner`)
3. Si le build échoue → SSH sur la machine et :
   ```bash
   sudo journalctl -u nixos-update-runner.service -n 200 --no-pager
   ```
4. Tester le build en local :
   ```bash
   nixos-rebuild dry-build --flake .#<hostname>
   ```
5. Vérifier qu'aucun secret agenix n'est cassé (vérifier `secrets/secrets.nix`)

### Ajouter un secret

```bash
# Dans nixos-config, éditer secrets/secrets.nix pour déclarer le secret
# Puis chiffrer avec agenix :
agenix -e secrets/<nom>.age
```

**Ne jamais commiter un secret en clair.** `.age` uniquement.

---

## Chaîne CI complète (rappel)

```
push my-nixpkgs/main
  → nix-cache.yml
    → nix build .#  (tous les paquets)
    → push to pcortellezzi.cachix.org
  → trigger-nixos-update.yml (if cache OK)
    → clone nixos-config
    → nix flake lock --update-input my-nixpkgs
    → commit + push flake.lock
      → deploy.yml (nixos-config)
        → Tailscale SSH vers chaque host
        → systemctl start nixos-update-runner
          → flock + nixos-rebuild switch
          → notify-send (desktop notification)
```

---

## Règles absolues (à ne jamais violer)

- **Ne pas modifier `hardware-configuration.nix`** — il est généré par `nixos-generate-config`
- **Ne pas commiter de secrets en clair** — tout passe par agenix (`.age`)
- **Ne pas casser l'ordre des overlays** dans my-nixpkgs — ils sont empilés séquentiellement
- **Ne pas supprimer `mkHost` ou changer sa signature** sans adapter tous les hôtes
- **Ne pas push directement sur main sans PR** — la CI déploie automatiquement
- **Ne pas utiliser `rec` dans `mkDerivation`** sauf si `version` est utilisée dans `src.url`
- **Toujours builder localement avant de push** : `nix flake check` ou `nix build .#<hostname>`
