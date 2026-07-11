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
        "zen"
        "thebrowsercompany-dia"
        "cursor"
        "zed"
        "visual-studio-code"
        "vlc"
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
