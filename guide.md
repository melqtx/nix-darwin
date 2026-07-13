# Dots Guide

This repository is the source of truth for the `prometheus` Apple Silicon Mac.
It combines nix-darwin for machine settings, Home Manager for the `melqtx`
account, nix-homebrew for native macOS software, and a small amount of
activation scripting for applications that cannot be managed with ordinary
Nix options.

## What this guide covers

The keybinding inventory below includes every shortcut explicitly declared,
remapped, or disabled by this repository. Applications still retain their
upstream default shortcuts unless the configuration says otherwise. Doom
Emacs, Helix, Vimium C, Atuin, and other applications have large upstream
default maps; those version-dependent defaults are not reproduced here because
the dots do not define them.

Key names used throughout:

- `Cmd` means the macOS Command/Super modifier.
- `Opt` and `Alt` refer to the same physical Option key. Ghostty exposes Option
  to terminal programs as Alt.
- `Ctrl` means Control.
- `Hyper` means holding the physical right Command key. macOS remaps that key
  to `F18`, and Hammerspoon turns `F18` into a modal shortcut layer.

## Architecture

`flake.nix` uses flake-parts and automatically imports every file whose name
ends in `.mod.nix`. Modules publish reusable nix-darwin and Home Manager
modules through options declared in `options/flake-outputs.mod.nix`.

The active system is assembled in
[`hosts/prometheus/prometheus.mod.nix`](hosts/prometheus/prometheus.mod.nix):

1. nix-darwin creates the `aarch64-darwin` system.
2. Home Manager manages the `melqtx` user.
3. nix-homebrew owns the declarative Homebrew installation.
4. The Darwin defaults, fonts, Helium, Homebrew, and package modules are
   imported.
5. The user module imports all shell, editor, terminal, version-control, and
   automation modules.

`nix.enable = false` is intentional. nix-darwin configures the machine but does
not install or replace Nix itself; it uses the existing Nix installation.

### Repository map

| Path | Responsibility |
| --- | --- |
| `flake.nix` | Inputs, platform, automatic module discovery |
| `checks.mod.nix` | Statix, deadnix, and nixfmt checks |
| `formatter.mod.nix` | `nix fmt` formatter |
| `hosts/prometheus/` | Active Mac and user assembly |
| `modules/darwin-defaults.mod.nix` | macOS defaults, Touch ID sudo, keyboard remap |
| `modules/fonts.mod.nix` | System fonts |
| `modules/helium.mod.nix` | Helium extensions and default-browser activation |
| `modules/homebrew.mod.nix` | Formulae, casks, and Mac App Store apps |
| `modules/packages.mod.nix` | Global Nix CLI and developer packages |
| `home/melqtx.mod.nix` | Home Manager entry point |
| `home/modules/` | User applications and dotfiles |

## Applying and checking changes

Run these from `~/dots`:

```sh
# Format every Nix file.
nix fmt

# Evaluate the complete working tree and run statix, deadnix, and nixfmt checks.
# The explicit path also includes new files before their first commit.
nix flake check path:.

# Build and activate the Mac configuration.
nh darwin switch path:$HOME/dots
```

`NH_FLAKE` also points to `~/dots`, but the Fish alias `rebuild` deliberately
uses the explicit `path:` form shown above. This includes newly created modules
before their first commit; ordinary Git-backed flake evaluation omits untracked
files.

For a lower-risk preflight before activation:

```sh
darwin-rebuild build --flake path:$HOME/dots#prometheus
```

The build evaluates and constructs the generation without changing the live
system. Activation may request sudo, and Touch ID is enabled for supported sudo
prompts.

## Package ownership

The package managers have deliberately separate jobs:

- Nix owns command-line tools, shells, editors, language servers, build tools,
  and fonts.
- Homebrew owns macOS applications and formulae that integrate more cleanly
  with the native platform.
- `mas` owns the selected Mac App Store applications through an explicit,
  interactive helper.

Homebrew activation uses `cleanup = "uninstall"`. A Homebrew formula or cask
that is installed but not declared in `modules/homebrew.mod.nix` may be removed
during the next switch. Add software to the module before relying on it.
Manually installed `.app` bundles are outside Homebrew cleanup.

### Newly added tools

| Tool | Owner | Behavior |
| --- | --- | --- |
| `glow` | Nix | Renders Markdown in the terminal; run `glow README.md` |
| `nmap` | Nix | Network discovery and port inspection |
| `mtr` | Nix | Live traceroute and packet-loss diagnostics |
| `ninja` | Nix | Fast build executor; CMake can use it with `-G Ninja` |
| `sccache` | Nix | Compiler cache, installed but not enabled globally |
| `lua-language-server` | Home Manager/Nix | Lua language intelligence; Helix can discover it |
| `mole` (`mo`) | Homebrew | macOS cleanup, uninstall, analysis, and maintenance CLI |

The configuration intentionally does not set `RUSTC_WRAPPER=sccache`, because a
global wrapper can surprise projects and CI scripts. Enable it per project:

```sh
RUSTC_WRAPPER=sccache cargo build
sccache --show-stats
```

`nmap` and ICMP-based `mtr` operations can require elevated raw-socket
permissions on macOS. Start without sudo and elevate only when the requested
scan requires it.

Mole is never run automatically. Preview destructive operations first:

```sh
mo clean --dry-run
mo purge --dry-run
mo uninstall --dry-run
```

### Tool inventory

- Nix maintenance: Home Manager, nh, nvd, nix-output-monitor, statix, deadnix,
  comma, nix-index, nixd, and nixfmt.
- Shell and terminal: Fish, Starship, Zellij, Zoxide, Atuin, direnv,
  nix-direnv, fzf, Carapace, and Television.
- Editors: Helix, Neovim, and Emacs 30.
- Search and files: ripgrep, fd, ast-grep, uutils, Eza, Bat, Yazi, wget, aria2,
  dua, Dust, ncdu, unzip, sd, and Hexyl.
- Structured data: jq, yq, gron, jnv, jless, and Miller.
- Monitoring and networking: Btop, Bottom, Bandwhich, Nmap, MTR, vnStat, xh,
  and aria2.
- Version control: Git, GitHub CLI, Jujutsu, jjui, lazyjj, Lazygit, Delta,
  Difftastic, Mergiraf, Watchman, GPG, and macOS Pinentry.
- Documentation and media: Glow, Pandoc, yt-dlp, ytfzf, FFmpeg, ImageMagick,
  ispell, and Hunspell.
- Developer utilities: Tokei, cloc, Fastfetch, Hyperfine, Watchexec, Just, Gum,
  ShellCheck, Procs, and peaclock.
- AI clients: `llm`, Codex, Claude Code, and Pi.
- Toolchains: Go, Node.js 24, pnpm, Bun, uv, fnm, CMake, GNU Make, Ninja,
  libtool, sccache, SQLite, GnuTLS, zstd, Temurin 25, and Gradle.

## macOS configuration

### Keyboard and sudo

- Touch ID authentication is enabled for sudo, including terminal multiplexers
  through PAM reattach support.
- The physical right Command key is remapped at the HID layer to `F18`.
- Hammerspoon consumes `F18` as the Hyper layer.
- The remap applies to the right Command key on every connected keyboard and is
  intended primarily for the external HHKB. That physical key no longer acts
  as an ordinary Command modifier.

### Dock, Finder, and global behavior

- The Dock auto-hides quickly and does not show recent applications.
- Finder shows hidden files, extensions, the path bar, and the status bar.
- Folders sort before files, Finder window titles contain the POSIX path, and
  Finder can be quit normally.
- Trash items older than 30 days are removed by Finder.
- The keyboard repeat delay is short and key repeat is fast.
- Tab and Shift-Tab can move keyboard focus through every control in dialogs.
- Press-and-hold accents and automatic capitalization, smart punctuation,
  inline prediction, and period insertion are disabled.
- Save and print panels start expanded.
- Documents save locally instead of defaulting to iCloud.
- Activating an application does not implicitly jump to one of its Spaces.
- Clicking in a scrollbar jumps to the clicked position.
- Holding `Ctrl` + `Cmd` while dragging anywhere in a window enables the macOS
  window-drag gesture.
- Time is 24-hour, measurements are metric, and temperature is Celsius.
- Personalized advertising is disabled.
- Network and USB volumes do not receive `.DS_Store` files.
- The screen locks immediately when the screensaver starts.
- Screenshots are PNG files without window shadows and are stored in
  `~/Pictures/screenshots`. Activation creates that directory when necessary.

### Fonts

Nix installs Fira Code, Fira Code Nerd Font, JetBrains Mono Nerd Font, the Noto
families, CJK sans/serif fonts, and Noto Color Emoji.

## Native macOS applications

Homebrew formulae:

- `mas`, `ffmpeg`, `imagemagick`, `vnstat`, `cloudflare-wrangler`, and `mole`.

Homebrew casks:

- Ghostty, Helium, Cloudflare WARP, AppCleaner, Notion Calendar, Signal,
  Firefox, Spotify, Discord, Vesktop, Telegram, Element, Little Snitch,
  Macs Fan Control, Hammerspoon, Zen, Dia, Cursor, Zed, Visual Studio Code,
  VLC, Obsidian, Raycast, T3 Code, OrbStack, and Prism Launcher.

Mac App Store applications:

- WhatsApp, uBlock Origin Lite, and iMovie are intentionally installed with
  `install-mas-apps`, not as Brewfile entries. MAS 7 requires root privileges
  and can request Apple Account or Touch ID authentication, while nix-darwin
  runs Homebrew Bundle as the primary user. Keeping this interactive prevents
  an App Store authentication problem from aborting the entire system
  activation.

## Helium

Helium is installed as a Homebrew cask. The system activation seeds external
extension descriptors for Dark Reader, Refined GitHub, SponsorBlock, Vimium C,
and Violentmonkey. Helium ships uBlock Origin itself.

The browser asks once before enabling externally seeded extensions. This avoids
Chromium enterprise policies and the permanent “managed by your organization”
label. Activation also removes policy files left by the old policy-based
approach and requests Helium as the default browser. macOS can show a
confirmation dialog when the default changes.

Home Manager seeds first-run preferences only when Helium's `Preferences` file
does not exist:

- onboarding and service consent are marked complete;
- vertical tabs are enabled;
- the rounded frame is disabled;
- new tabs open next to the active tab;
- the bookmark bar is shown without tab groups;
- downloads ask for a destination.

Incognito access for extensions must be changed manually at
`helium://extensions`.

## Fish shell

Fish is the interactive shell. Its path order deliberately puts Nix ahead of
Homebrew, and also includes `~/.local/bin`, `~/go/bin`, and Doom's
`~/.config/emacs/bin`.

Interactive shells initialize Starship, Zoxide, Atuin, direnv, fzf, fnm, and
Carapace. These tools may provide their own version-dependent default Fish
bindings, but this repository declares no Fish `bind` command directly.

### Fish functions

| Function | Effect |
| --- | --- |
| `battle` | Changes to `~/code` and opens Zellij with the `battlestation` layout |
| `battlestation` | Alias function for `battle` |
| `install-mas-apps` | Interactively acquire/install WhatsApp, iMovie, and uBlock Origin Lite |

### Fish aliases

| Alias | Expansion or purpose |
| --- | --- |
| `zi` | Interactive Zoxide directory query |
| `yy` | Yazi |
| `js` | `jj status` |
| `ja`, `ga` | `jj file track` |
| `jc` | `jj commit` |
| `jd` | `jj diff` |
| `jl`, `lg` | `jj log` |
| `jn` | `jj new` |
| `jsh` | `jj show` |
| `ju` | `jj undo` |
| `log` | Personal `1337/bin/log` script |
| `ls` | Eza, icons, directories first |
| `l` | Eza including hidden files, sorted by date |
| `ll` | Long Eza listing, sorted by name |
| `la` | Long Eza listing with Git data, sorted by date |
| `lt` | Eza tree including hidden files |
| `lr` | Recursive Eza listing |
| `tree` | Eza tree |
| `cat` | Bat |
| `grep` | Ripgrep |
| `find` | fd |
| `du` | Dust |
| `ps` | Procs |
| `top` | Btop |
| `btm` | Bottom |
| `http` | xh |
| `diff` | Delta |
| `sed` | sd |
| `cls` | Clear the terminal |
| `vim`, `nvim`, `nv` | Neovim |
| `v`, `hx` | Helix |
| `emacs`, `e` | Terminal Emacs client, starting the daemon if needed |
| `eg` | New graphical Emacs client frame |
| `rebuild` | `nh darwin switch path:$HOME/dots` |
| `dots` | Change to `~/dots` |
| `zj` | Zellij |
| `fish` | Absolute Nix-managed Fish executable |

`ga` is intentionally a Jujutsu tracking command, not `git add`.

## Ghostty

Ghostty starts Zellij directly with the `clean` layout. It uses Fira Code at
15pt, the Vesper theme, a transparent macOS titlebar, Display P3 color, fixed
padding, a block cursor, clipboard copy-on-select, and Option-as-Alt.

The quick terminal opens on the screen under the mouse, fills that screen, has
no animation, does not auto-hide, and captures keyboard input exclusively.

### Ghostty shortcuts

| Shortcut | Action |
| --- | --- |
| `Ctrl` + backtick | Globally toggle the quick terminal |
| `Shift` + `Enter` | Send the byte sequence Escape followed by carriage return |

Ghostty bindings explicitly disabled so Zellij or the terminal application can
receive them:

| Disabled in Ghostty |
| --- |
| `Cmd` + `T` |
| `Cmd` + `W` |
| `Cmd` + `H` |
| `Cmd` + `L` |
| `Cmd` + `Shift` + `T` |
| `Cmd` + `Shift` + `W` |
| `Cmd` + `Shift` + `H` |
| `Cmd` + `Shift` + `L` |
| `Ctrl` + `H` |
| `Ctrl` + `J` |
| `Ctrl` + `K` |
| `Ctrl` + `L` |

macOS menu-item overrides move Ghostty's ordinary Hide shortcuts out of the
way:

| Shortcut | Menu action |
| --- | --- |
| `Cmd` + `Opt` + `Ctrl` + `Shift` + `H` | Hide Ghostty |
| `Cmd` + `Opt` + `Ctrl` + `Shift` + `O` | Hide Others |

## Zellij

Zellij uses Fish, the `clean` layout, the Vesper theme, no pane frames, no mouse
mode, system clipboard integration through `pbcopy`, stacked resizing, and no
session serialization.

All shortcuts below work in every Zellij mode except locked mode.

### Focus panes

| Shortcut | Action |
| --- | --- |
| `Ctrl` + `H` | Focus pane to the left |
| `Ctrl` + `J` | Focus pane below |
| `Ctrl` + `K` | Focus pane above |
| `Ctrl` + `L` | Focus pane to the right |

### Tabs

| Shortcut | Action |
| --- | --- |
| `Cmd` + `H` | Previous tab |
| `Cmd` + `L` | Next tab |
| `Cmd` + `T` | Create a tab and immediately name it |
| `Cmd` + `W` | Close the current tab |
| `Cmd` + `R` | Rename the current tab |
| `Cmd` + `Shift` + `H` | Previous tab |
| `Cmd` + `Shift` + `L` | Next tab |
| `Cmd` + `Shift` + `T` | Create a tab and immediately name it |
| `Cmd` + `Shift` + `W` | Close the current tab |

### Move panes

| Shortcut | Action |
| --- | --- |
| `Ctrl` + `Shift` + `H` | Move pane left |
| `Ctrl` + `Shift` + `J` | Move pane down |
| `Ctrl` + `Shift` + `K` | Move pane up |
| `Ctrl` + `Shift` + `L` | Move pane right |
| `Ctrl` + `Shift` + `W` | Close the focused pane |

### Create panes

| Shortcut | Action |
| --- | --- |
| `Alt` + `H` | New pane to the left |
| `Alt` + `J` | New pane below |
| `Alt` + `K` | New pane above |
| `Alt` + `L` | New pane to the right |
| `Alt` + `V` | New pane to the right |
| `Alt` + `S` | New pane below |
| `Alt` + `Shift` + `S` | New stacked pane |

### Resize panes

| Shortcut | Action |
| --- | --- |
| `Ctrl` + `Alt` + `H` | Increase toward the left |
| `Ctrl` + `Alt` + `J` | Increase downward |
| `Ctrl` + `Alt` + `K` | Increase upward |
| `Ctrl` + `Alt` + `L` | Increase toward the right |
| `Ctrl` + `Alt` + `Shift` + `H` | Decrease from the left |
| `Ctrl` + `Alt` + `Shift` + `J` | Decrease from below |
| `Ctrl` + `Alt` + `Shift` + `K` | Decrease from above |
| `Ctrl` + `Alt` + `Shift` + `L` | Decrease from the right |

### Pane and session controls

| Shortcut | Action |
| --- | --- |
| `Ctrl` + `F` | Toggle focused pane fullscreen |
| `Ctrl` + `P` | Create a pane and toggle it between embedded and floating |
| `Ctrl` + `Shift` + `P` | Show or hide floating panes |
| `Ctrl` + `Q` | Quit Zellij |
| `Ctrl` + `D` | Detach from the session |

### Layouts

The default `clean` layout starts four tabs:

- `main`, focused at startup;
- `dots`, rooted at `~/dots`;
- `work`, rooted at `~/code`;
- `scratch`.

The `battlestation` layout opens five code panes in a wide three-column
arrangement and adds the tab bar at the bottom.

## Hammerspoon

Hammerspoon provides the window manager and an input-activity counter.

The counter records counts and distances, not typed characters or clipboard
contents. It stores totals in `~/.local/state/input-stats.json` and flushes
changes every five seconds. A personal script publishes the totals daily at
21:00; the manual shortcut below publishes immediately.

Hammerspoon requires macOS Accessibility and Input Monitoring permissions for
global shortcuts, window control, and input-event counting.

### Global Hammerspoon shortcut

| Shortcut | Action |
| --- | --- |
| `Cmd` + `Opt` + `Ctrl` + `S` | Flush and publish input statistics, with a notification |

### Hyper window focus

Hold physical right Command and press:

| Shortcut | Action |
| --- | --- |
| `Hyper` + `H` | Focus the window to the west |
| `Hyper` + `J` | Focus the window to the south |
| `Hyper` + `K` | Focus the window to the north |
| `Hyper` + `L` | Focus the window to the east |

### Hyper window placement

| Shortcut | Action |
| --- | --- |
| `Hyper` + `Shift` + `H` | Move the focused window to the left half |
| `Hyper` + `Shift` + `J` | Move the focused window to the bottom half |
| `Hyper` + `Shift` + `K` | Move the focused window to the top half |
| `Hyper` + `Shift` + `L` | Move the focused window to the right half |

### Hyper window resizing

Each press changes one dimension by five percent of the current screen. Width
never drops below 320 pixels and height never drops below 240 pixels.

| Shortcut | Action |
| --- | --- |
| `Hyper` + `Ctrl` + `H` | Reduce width |
| `Hyper` + `Ctrl` + `J` | Increase height |
| `Hyper` + `Ctrl` + `K` | Reduce height |
| `Hyper` + `Ctrl` + `L` | Increase width |

### Other Hyper actions

| Shortcut | Action |
| --- | --- |
| `Hyper` + `F` | Toggle native macOS fullscreen |
| `Hyper` + `C` | Center the focused window |
| `Hyper` + `Shift` + `1` | Move the focused window to display 1 |
| `Hyper` + `Shift` + `2` | Move the focused window to display 2 |
| `Hyper` + `Shift` + `3` | Move the focused window to display 3 |

If the requested display is not connected, Hammerspoon shows an alert instead
of moving the window.

## Helix

Helix is the default `$EDITOR` and `$VISUAL`. It enables LSP completion, inlay
hints, inline diagnostics, soft wrapping, focus-lost auto-save, absolute line
numbers, and the Catppuccin Mocha theme.

### Helix custom shortcuts

| Mode | Shortcut | Action |
| --- | --- | --- |
| Insert | `Esc` | Collapse the selection and return to normal mode |
| Normal | `w` | Next word start, then collapse selection |
| Normal | `e` | Next word end, then collapse selection |
| Normal | `b` | Previous word start, then collapse selection |
| Normal | `h` | Move one character left, then collapse selection |
| Normal | `j` | Move down one visual line, then collapse selection |
| Normal | `k` | Move up one visual line, then collapse selection |
| Normal | `l` | Move one character right, then collapse selection |
| Normal | `Space`, `y`, `p` | Copy the current buffer path to the macOS clipboard |
| Normal | `Space`, `y`, `g` | Copy a GitHub permalink for the current Jujutsu commit and line |

The GitHub permalink helper expects a Jujutsu workspace with a GitHub `origin`.

### Language tooling

| Language | Formatter | Language server or debugger |
| --- | --- | --- |
| Nix | nixfmt | nixd |
| Rust | rustfmt | rust-analyzer, clippy checks, LLDB DAP |
| Go | gofumpt | gopls with staticcheck, Delve |
| Python | Ruff | ty, debugpy |
| TypeScript/JavaScript | Prettier | typescript-language-server |
| Haskell | Fourmolu | haskell-language-server |
| Zig | `zig fmt` | zls |
| Java | google-java-format | jdtls |
| JSON/HTML/CSS | Prettier | VS Code language servers |
| YAML | Prettier | yaml-language-server |
| Lua | Helix built-in formatter behavior | lua-language-server |

## Doom Emacs

Nix installs Emacs 30 and runs it as a user service. Home Manager owns Doom's
`init.el`, `config.el`, and `packages.el`, but Doom itself bootstraps into
`~/.config/emacs` because its package manager fetches modules over Git.

The first activation requires network access. Every later activation runs
`doom sync`. Fish's `emacs`/`e` aliases open a terminal client, and `eg` opens a
graphical frame.

Doom enables Evil, Company, Vertico, workspaces, Treemacs, Magit, LSP,
Tree-sitter, direnv, Org, Org-roam, Nix, web, JavaScript, JSON, Markdown, and
shell support.

### Custom Doom keybindings

These are the only Emacs bindings explicitly added by this repository:

| Shortcut | Action |
| --- | --- |
| `C-c n l` | Toggle the Org-roam buffer |
| `C-c n f` | Find an Org-roam node |
| `C-c n g` | Open the Org-roam graph |
| `C-c n i` | Insert an Org-roam node |
| `C-c n c` | Capture an Org-roam node |
| `C-c n j` | Capture today's daily note |

Org files live in `~/Documents/org`, with Org-roam notes under
`~/Documents/org/roam`. Capture templates separate main notes, references, and
articles.

## Version control

Git uses `main` as the default branch, Neovim as its configured editor, the
macOS Keychain credential helper, pruning on fetch, and object verification on
fetch, receive, and transfer.

Jujutsu is the primary interactive workflow:

- Difftastic renders diffs.
- Mergiraf provides syntax-aware conflict resolution through `jj resolve-ast`.
- Watchman provides filesystem monitoring and ignores `.direnv`,
  `node_modules`, and `target`.
- New pushed bookmarks use `melqtx/change-<change-id>`.
- New remote bookmarks matching `melqtx/*` are automatically tracked.

Jujutsu aliases:

| Alias | Command |
| --- | --- |
| `jj a` | `jj file track` |
| `jj c` | `jj commit` |
| `jj d` | `jj diff` |
| `jj e` | `jj edit` |
| `jj l` | `jj log` |
| `jj n` | `jj new` |
| `jj s` | `jj status` |
| `jj sh` | `jj show` |
| `jj u` | `jj undo` |
| `jj resolve-ast` | Resolve with Mergiraf |

GPG and the macOS Pinentry agent are enabled, but commit signing remains
disabled until a concrete private key is declared.

## SSH and terminal tooling

SSH includes OrbStack's generated host configuration and multiplexes
connections for 60 minutes. Agent and connection forwarding are disabled.
Connections receive `COLORTERM=truecolor`, and dead connections are detected
with 30-second server-alive messages.

Man pages render through Bat. Ripgrep defaults to line numbers and smart case.
The configured `LESS` behavior keeps color, supports incremental search, avoids
wrapping long lines, and exits automatically for one-screen output.

## Claude Code

Claude Code receives a declarative allowlist for read-only repository
inspection using tools such as ripgrep, Jujutsu, Git, GitHub CLI, and selected
Nix evaluation commands. Recursive `find` operations over `/nix/store` are
blocked because they can effectively hang a session. Feedback, error reporting,
and telemetry environment flags are disabled.

## Syncthing

Home Manager enables Syncthing for the user and ensures its log directory
exists at `~/Library/Logs/Syncthing`. Folder and peer declarations are not
managed in this repository.

## Rectangle

Rectangle is currently present as a manually installed application at
`/Applications/Rectangle.app`; it is not declared as a Homebrew cask. Its
preference domain also still contains custom shortcuts and mouse-snapping
settings.

Hammerspoon already covers:

- directional window focus;
- left, right, top, and bottom halves;
- incremental resizing;
- centering;
- native fullscreen;
- moving windows among three displays.

Rectangle still provides features the current Hammerspoon module does not
exactly reproduce, principally mouse-edge snapping and non-fullscreen maximize.
If those two features are not part of the daily workflow, Rectangle is
redundant and can be removed after confirming that Hammerspoon has Accessibility
permission. Removing it also eliminates a second independent window-shortcut
engine.

Because the app was installed manually, Homebrew cleanup will not remove it.
This repository deliberately does not delete the app or its preferences.

## Safe extension rules

- Put portable CLI tools in `modules/packages.mod.nix`.
- Put language servers and formatters in
  `home/modules/language-tools.mod.nix`.
- Put native applications and Mac-specific formulae in
  `modules/homebrew.mod.nix`.
- Put per-user configuration in a focused module under `home/modules/`.
- Before adding a shortcut, search Ghostty, Zellij, Hammerspoon, Helix, Doom,
  and macOS defaults for the complete chord.
- Keep destructive maintenance tools opt-in and preview their work first.
- Run `nix fmt`, `nix flake check path:.`, and a Darwin build before
  activation.
