{ ... }:

{
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
    ];

    casks = [
      "ghostty"

      "cursor"
      "zed"
      "visual-studio-code"

      "orbstack"

      "font-jetbrains-mono-nerd-font"
    ];
  };
}
