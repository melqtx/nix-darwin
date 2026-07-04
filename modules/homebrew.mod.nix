{ ... }:

{
  flake.darwinModules.homebrew = {
    # Pin and manage the Homebrew installation itself declaratively. autoMigrate
    # adopts the existing /opt/homebrew (owned by melqtx) instead of reinstalling.
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
        cleanup = "none";
      };

      brews = [
        "ffmpeg"
        "imagemagick"
        "vnstat"
        "cloudflare-wrangler"
      ];

      casks = [
        "ghostty"
        "cloudflare-warp"
        "appcleaner"
        "notion-calendar"
        "signal"
        "firefox"
        "spotify"
        "discord"
        "whatsapp"
        "telegram"
        "element"
        "macs-fan-control"
        "hammerspoon"
        "amethyst"
        "zen"
        "thebrowsercompany-dia"
        "cursor"
        "zed"
        "visual-studio-code"
        "obsidian"
        "raycast"
        "t3-code"
        "orbstack"

        "font-jetbrains-mono-nerd-font"
        "prismlauncher"
      ];
    };
  };
}
