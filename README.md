# dots

Tiny Nix-powered macOS den. Terminal-first, jj-friendly, and only mildly haunted by yak shaving.

See [`guide.md`](guide.md) for the architecture, activation workflow, package
ownership, application behavior, and complete managed-keybinding reference.

## Tree

```text
.
├── README.md
├── guide.md
├── flake.lock
├── flake.nix
├── home
│   ├── melqtx.mod.nix
│   └── modules
│       ├── claude-code.mod.nix
│       ├── emacs.mod.nix
│       ├── fish.mod.nix
│       ├── ghostty.mod.nix
│       ├── hammerspoon.mod.nix
│       ├── helium.mod.nix
│       ├── helix.mod.nix
│       ├── language-tools.mod.nix
│       ├── starship.mod.nix
│       ├── tooling.mod.nix
│       ├── version-control.mod.nix
│       └── zellij.mod.nix
├── hosts
│   └── prometheus
│       └── prometheus.mod.nix
├── modules
│   ├── darwin-defaults.mod.nix
│   ├── fonts.mod.nix
│   ├── helium.mod.nix
│   ├── homebrew.mod.nix
│   └── packages.mod.nix
└── options
    └── flake-outputs.mod.nix
```
