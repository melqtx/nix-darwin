{ ... }:

{
  flake.darwinModules.homebrew = {
    nix-homebrew = {
      enable = true;
      user = "melqtx";
      autoMigrate = true;
    };

    homebrew = {
      enable = true;

      onActivation = {
        autoUpdate = true;
        upgrade = true;
        # Remove anything brew-installed that isn't declared here, so strays
        # can't shadow the nix copies (see: the go 1.26.5 incident).
        cleanup = "uninstall";
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
        "ghostty"
        "kitty"
        "wezterm"
        "helium-browser"
        "cloudflare-warp"
        "appcleaner"
        "notion-calendar"
        "signal"
        "firefox"
        "spotify"
        "discord"
        "vesktop"
        "telegram"
        "element"
        "little-snitch"
        "macs-fan-control"
        "hammerspoon"
        "zen"
        "thebrowsercompany-dia"
        "cursor"
        "zed"
        "visual-studio-code"
        "vlc"
        "obsidian"
        "raycast"
        "vorssaint"
        "t3-code"
        "orbstack"

        "prismlauncher"
      ];

      # MAS 7 requires interactive root and, for newly acquired apps, Apple
      # Account authentication. nix-darwin runs this Brew bundle as the
      # primary user, so homebrew.masApps would make every rebuild fail.
      # `install-mas-apps` in the Fish module performs this interactive step.
    };
  };
}
