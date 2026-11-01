{ inputs, ... }:

{
  flake.darwinModules.homebrew =
    { config, lib, ... }:
    let
      inherit (lib.lists) singleton;
    in
    {
      imports = singleton inputs.nix-homebrew.darwinModules.nix-homebrew;

      nix-homebrew = {
        enable = true;
        user = config.system.primaryUser;
        autoMigrate = true;
        mutableTaps = false;
        # nix-homebrew still defaults to 7.0.4; the core tap uses :test
        # resources, which that version tries to instantiate as Ruby classes.
        package = inputs.homebrew-brew // {
          name = "brew-7.0.11";
          version = "7.0.11";
        };
        taps = {
          "homebrew/homebrew-core" = inputs.homebrew-core;
          "homebrew/homebrew-cask" = inputs.homebrew-cask;
          "anomalyco/homebrew-tap" = inputs.homebrew-anomalyco;
          "crmne/homebrew-tap" = inputs.homebrew-crmne;
          "manaflow-ai/homebrew-cmux" = inputs.homebrew-cmux;
          "qmk/homebrew-qmk" = inputs.homebrew-qmk;
        };
      };

      system.activationScripts.setup-homebrew.text = lib.mkBefore (
        lib.optionalString (config.nix-homebrew.autoMigrate && !config.nix-homebrew.mutableTaps) (
          lib.concatMapStringsSep "\n" (
            prefix:
            let
              taps = lib.escapeShellArg "${prefix.library}/Taps";
              backup = lib.escapeShellArg "${prefix.library}/Taps.before-nix.XXXXXX";
            in
            ''
              if [ -d ${taps} ] && [ ! -L ${taps} ]; then
                taps_backup=$(/usr/bin/mktemp -d ${backup})
                /bin/mv ${taps} "$taps_backup/Taps"
                /bin/chmod 755 "$taps_backup"
                echo "Saved existing Homebrew taps to $taps_backup/Taps" >&2
              fi
            ''
          ) (lib.filter (prefix: prefix.enable) (lib.attrValues config.nix-homebrew.prefixes))
        )
      );

      homebrew = {
        enable = true;
        taps = lib.attrsets.attrNames config.nix-homebrew.taps;

        onActivation = {
          # Keep rebuilds fast and non-destructive. Update/upgrade explicitly
          # with Homebrew when desired instead of doing it during activation.
          autoUpdate = false;
          upgrade = false;
          cleanup = "none";
        };

        brews = [
          "mas"
          "ffmpeg"
          "imagemagick"
          "vnstat"
          "cloudflare-wrangler"
          "mole"
        ];

        casks = [
          "kitty"
          "wezterm"
          "cloudflare-warp"
          "appcleaner"
          "notion-calendar"
          "signal"
          "firefox"
          "spotify"
          "discord"
          "telegram"
          "element"
          "little-snitch"
          "macs-fan-control"
          "thebrowsercompany-dia"
          "cursor"
          "visual-studio-code"
          "vlc"
          "obsidian"
          "raycast"
          "vorssaint"
          "t3-code"
          "orbstack"

          "prismlauncher"
          "osu"
        ];

        # MAS 7 requires interactive root and, for newly acquired apps, Apple
        # Account authentication. nix-darwin runs this Brew bundle as the
        # primary user, so homebrew.masApps would make every rebuild fail.
        # `install-mas-apps` in the Fish module performs this interactive step.
      };
    };
}
