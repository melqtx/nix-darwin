{ ... }:

{
  flake.darwinModules.cli-tools =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        pkgs.fd
        pkgs.uutils-coreutils-noprefix
        pkgs.uutils-findutils
        pkgs.uutils-diffutils
        pkgs.eza
        pkgs.bat
        pkgs.less
        pkgs.wget
        pkgs.aria2
        pkgs.unzip
        pkgs.zstd
        pkgs.tldr
        pkgs.television
        pkgs.glow
        pkgs.peaclock
        pkgs.yt-dlp
        pkgs.ytfzf
        pkgs.gum
        pkgs.ispell
        pkgs.hunspell
      ];
    };
}
