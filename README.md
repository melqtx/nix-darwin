# dots

```text
.
├── README.md
├── RUST-WEEK.md
├── checks.mod.nix
├── flake.lock
├── flake.nix
├── formatter.mod.nix
├── home
│   ├── melqtx.mod.nix
│   └── modules
│       ├── atuin.mod.nix
│       ├── claude-code.mod.nix
│       ├── emacs.mod.nix
│       ├── fish.mod.nix
│       ├── ghostty.mod.nix
│       ├── hammerspoon.mod.nix
│       ├── helium.mod.nix
│       ├── helium
│       │   └── ublock-youtube.txt
│       ├── helix.mod.nix
│       ├── language-tools.mod.nix
│       ├── pi.mod.nix
│       ├── starship.mod.nix
│       ├── tooling.mod.nix
│       ├── version-control.mod.nix
│       ├── vesktop.mod.nix
│       ├── zed.mod.nix
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
├── options
│   └── flake-outputs.mod.nix
└── statix.toml
```

## System updates

Update inputs, check, and build before switching:

```sh
nix flake update --flake path:$HOME/dots
nix flake check path:$HOME/dots
nix build path:$HOME/dots#darwinConfigurations.prometheus.system --no-link
sudo darwin-rebuild switch --flake path:$HOME/dots#prometheus
```

`rebuild` in Fish also switches this configuration. Homebrew activation does
not upgrade or remove existing apps. Vesktop is managed by Homebrew, with its
self-updater disabled; upgrade it explicitly with `brew upgrade --cask --greedy vesktop`.

Each rebuild disables both Spotlight shortcuts, leaving Raycast's shortcut
alone and preserving unrelated macOS shortcuts. If macOS does not reload them
immediately, log out and back in.

Before switching, record `readlink /run/current-system`. For rollback, use
`sudo darwin-rebuild switch --rollback`, or run the saved generation's
`activate` script with sudo. This restores the Nix generation, not Homebrew app
versions or mutable user preferences. Keep backups of those separately.

## Terminal sessions

Ghostty starts or attaches to the shared Zellij session `main`. New sessions
use the `clean` layout with `main`, `dots`, `work`, and `scratch` tabs. Existing
sessions keep their layouts; the rebuild does not kill or recreate them.

Cmd+T creates a Zellij tab, Cmd+W closes one, Cmd+H/L switches tabs, and Cmd+R
renames the tab. Ctrl+H/J/K/L moves pane focus. Ctrl+backtick toggles Ghostty's
quick terminal. Detach with Ctrl+D; quit with Ctrl+Q.

From a plain shell, `zj` attaches to a session for the current Git project or
directory; `zj <name>` uses an explicit name. It refuses to nest sessions.
`battle` remains the explicit battlestation layout.

Atuin owns Ctrl+R and Up-arrow history search. fzf keeps Ctrl+T for files and
Alt+C for directories, without replacing Ctrl+R. Atuin's `?` AI binding is
disabled. Enter still executes a selected history entry; Tab inserts it for
editing. History, sync credentials, and encryption keys stay outside the repo.

## Rust week

Zed is the default editor and owns the shared Rust tasks and rust-analyzer
settings. See [RUST-WEEK.md](RUST-WEEK.md) for the seven-day trial plan.
