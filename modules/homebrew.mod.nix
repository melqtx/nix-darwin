{ ... }:

{
  flake.darwinModules.homebrew = {
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
        "telegram"
        "element"
        "macs-fan-control"

        "cursor"
        "zed"
        "visual-studio-code"

        "orbstack"

        "font-jetbrains-mono-nerd-font"
        "prismlauncher"
      ];
    };
  };
}
