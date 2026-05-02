# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Apply configuration to the current host
sudo nixos-rebuild switch --flake .#storage-r710

# Format all Nix files
nix fmt

# Check flake outputs are valid
nix flake check

# Update flake inputs
nix flake update
```

## Architecture

This is a personal NixOS configuration using flakes with home-manager. It targets two machines: `storage-r710` (server, currently active in `flake.nix`) and `amdpc` (AMD desktop, defined in `host/amdpc/` but not currently exported).

**Inputs**: `nixpkgs` and `home-manager` pin to `release-25.11`; an `unstable` input is also threaded through via an overlay (`pkgs.unstable.<package>`).

### Directory layout

- `flake.nix` — entry point; `nixosConfigurations` entries pass a `builderOptions` attrset as `specialArgs` to toggle features per host
- `host/<name>/default.nix` — host-specific NixOS config (networking, services, hardware imports); imports `host/common.nix` and the relevant modules
- `host/common.nix` — settings shared across all hosts (locale, nix settings, user creation via `module/user.nix`)
- `module/` — reusable NixOS modules; each module reads from `builderOptions` to conditionally enable itself
- `home-manager/common.nix` — shared home-manager config (bash, git, neovim, tmux); imported by every host's home-manager module
- `home-manager/<name>/default.nix` — host-specific home-manager additions
- `dotfile/` — actual dotfiles managed by home-manager (neovim config under `.config/nvim/`, tmux, etc.); symlinked into `$HOME` at activation
- `module/pkgs/` — custom package derivations (e.g. `devcontainer-cli.nix`, GTK themes, printer drivers)
- `module/container.nix` — Docker/Podman container services (Traefik, Jellyfin, Nextcloud, Coder, qBittorrent, etc.); controlled by `builderOptions.container.*` flags

### `builderOptions` pattern

Hosts pass feature flags through `specialArgs.builderOptions` in `flake.nix`. Modules receive these via `specialArgs` and gate their configuration on them, e.g.:

```nix
{ builderOptions, ... }:
{
  config = lib.mkIf builderOptions.gui.enable { ... };
}
```

To add a new toggleable feature: add a flag to `builderOptions` in `flake.nix`, read it in the relevant module.

### Unstable packages

An overlay injects `pkgs.unstable` so any module can use `pkgs.unstable.<package>` to pull from `nixos-unstable` while the rest of the system tracks the stable release.
