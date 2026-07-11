{ ... }:

{
  flake.darwinModules.packages =
    { lib, pkgs, ... }:
    let
      inherit (lib.lists) elem singleton;
      inherit (lib.strings) getName;

      gradle = pkgs.gradle.override {
        gradle-unwrapped = pkgs.gradle-unwrapped.override {
          java = pkgs.temurin-bin-25;
          javaToolchains = singleton pkgs.temurin-bin-25;
        };
      };
    in
    {
      nixpkgs.config.allowUnfreePredicate = pkg: elem (getName pkg) (singleton "claude-code");

      environment.variables = {
        JAVA_HOME = "${pkgs.temurin-bin-25}";
      };

      environment.systemPackages = [
        pkgs.home-manager
        pkgs.nh
        pkgs.nvd
        pkgs.nix-output-monitor
        pkgs.statix
        pkgs.deadnix
        pkgs.comma

        pkgs.fish
        pkgs.starship
        pkgs.zellij
        pkgs.neovim
        pkgs.emacs30

        pkgs.zoxide
        pkgs.atuin
        pkgs.direnv
        pkgs.nix-direnv
        pkgs.fzf
        pkgs.git

        pkgs.ripgrep
        pkgs.fd
        pkgs.ast-grep
        pkgs.uutils-coreutils-noprefix
        pkgs.uutils-findutils
        pkgs.uutils-diffutils

        pkgs.eza
        pkgs.bat
        pkgs.yazi
        pkgs.wget
        pkgs.aria2
        pkgs.dua
        pkgs.dust
        pkgs.procs
        pkgs.ncdu
        pkgs.unzip

        pkgs.jq
        pkgs.yq
        pkgs.gron
        pkgs.jnv
        pkgs.jless
        pkgs.miller

        pkgs.btop
        pkgs.bottom
        pkgs.bandwhich

        pkgs.tldr
        pkgs.llm
        pkgs.codex
        pkgs.claude-code
        pkgs.television
        pkgs.pfetch-rs
        pkgs.tokei
        pkgs.cloc
        pkgs.fastfetch
        pkgs.hyperfine
        pkgs.watchexec
        pkgs.sd
        pkgs.just
        pkgs.difftastic
        pkgs.hexyl
        pkgs.xh
        pkgs.peaclock
        pkgs.pandoc
        pkgs.yt-dlp
        pkgs.ytfzf
        pkgs.gum
        pkgs.shellcheck
        pkgs.ispell
        pkgs.hunspell

        pkgs.go
        pkgs.nodejs_24
        pkgs.pnpm
        pkgs.bun
        pkgs.uv
        pkgs.fnm
        pkgs.cmake
        pkgs.gnumake
        pkgs.libtool
        pkgs.sqlite
        pkgs.gnutls
        pkgs.zstd
        pkgs.temurin-bin-25
        gradle
      ];
    };
}
