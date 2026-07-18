## T7: hermes-workspace service module

- Created `modules/services/hermes-workspace.nix` at 2026-07-05
- Module imports `inputs.hermes-workspace.nixosModules.default` — `inputs` is available via `specialArgs` from `mkHost` in `flake.nix`
- Configures the upstream module with host=0.0.0.0, port=3000, API URLs pointing to localhost
- `nix flake check` cannot run because `hermes-agent`/`hermes-workspace` GitHub repos don't exist yet (404)
- Nix syntax verified with `nix-instantiate --parse` — valid
- The `hermes-workspace` flake input was already added to `flake.nix` (T4 completed before this task)
