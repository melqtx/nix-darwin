{ ... }:

{
  flake.darwinModules.fonts =
    { pkgs, ... }:
    {
      fonts.packages = [
        pkgs.fira-code
        pkgs.nerd-fonts.fira-code
        pkgs.nerd-fonts.jetbrains-mono
        pkgs.noto-fonts
        pkgs.noto-fonts-cjk-sans
        pkgs.noto-fonts-cjk-serif
        pkgs.noto-fonts-color-emoji
      ];
    };
}
