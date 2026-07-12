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

      pi = pkgs.buildNpmPackage (finalAttrs: {
        pname = "pi-coding-agent";
        version = "0.80.6";

        src = pkgs.fetchurl {
          url = "https://registry.npmjs.org/@earendil-works/pi-coding-agent/-/pi-coding-agent-${finalAttrs.version}.tgz";
          hash = "sha256-KndjRkCy2G2Q0kCHu2dVns8jZuD7UqQsVe7UFhR9pBE=";
        };

        # the published shrinkwrap lacks integrity for pi's own sibling
        # packages, and devDependencies are absent from it entirely
        postPatch = ''
          ${lib.getExe pkgs.jq} '
            .packages["node_modules/@earendil-works/pi-agent-core"].integrity = "sha512-Lvn89ko42h5ETUb6Z0Ku6ldskEqXaTdQBYvSa0+7bdG9V6rUEpXptv5e0OVZ1HDcvi8s6/2lGCQWsxKX+DFHNw==" |
            .packages["node_modules/@earendil-works/pi-ai"].integrity = "sha512-7xfLk8sANBp+bpPEbjoOZTbPxsa+++b1JXAoSJsNa3vbs9AHHEclmvg54XLQcxH+fuwaeti/g2jeIfJ+mVYLpA==" |
            .packages["node_modules/@earendil-works/pi-tui"].integrity = "sha512-bSuzS4EVSqEPj/Qr/p9eqCESfKsGuDNbl77EGci8Iaqqt/C/XCBZL1MjXaxSWW1NsT5afjp/Cb0NTPzOLv/aPA=="
          ' npm-shrinkwrap.json > package-lock.json
          cp package-lock.json npm-shrinkwrap.json

          ${lib.getExe pkgs.jq} 'del(.devDependencies)' package.json > package.json.tmp
          mv package.json.tmp package.json
        '';

        npmDepsHash = "sha256-YCOHHaIvYWj/OgaIQgs/HzhgslbyVLbUe98kEP5F0Jo=";

        dontNpmBuild = true;

        meta.mainProgram = "pi";
      });
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
        pi
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
