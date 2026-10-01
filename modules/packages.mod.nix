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
        version = "0.84.4";

        src = pkgs.fetchurl {
          url = "https://registry.npmjs.org/@earendil-works/pi-coding-agent/-/pi-coding-agent-${finalAttrs.version}.tgz";
          hash = "sha256-W852bRnDzroY8/uq2RxEnJ+dc5gfnjQA7O+TIAbwaWg=";
        };

        # the published shrinkwrap lacks integrity for pi's own sibling
        # packages, and devDependencies are absent from it entirely
        postPatch = ''
          ${lib.getExe pkgs.jq} '
            .packages["node_modules/@earendil-works/pi-agent-core"].integrity = "sha512-HyUnjaOXj6oN/6SNcr8A1J/ElRQA50FtIE0XUTSKAQVqmdlb9qdojOyUQwF/jULE5+yOEtGuVgi/N1RnBiNG+g==" |
            .packages["node_modules/@earendil-works/pi-ai"].integrity = "sha512-AClAZxf5+c4RRu44NJPS6wyQy+Nmq+Mzyyrdvm4ZVMNuixelO02RZX4G4Aq1F145Yzp43wnM5S+hLlSI7ypfVw==" |
            .packages["node_modules/@earendil-works/pi-client"].integrity = "sha512-q398WY/3ZQHTizk7IKxApzqFV0xt4yM9LkSkwyqeLK5Bj5RwRjOWxESt26z4LgNp4O+8hqhqFPf/8fj4H5rE4A==" |
            .packages["node_modules/@earendil-works/pi-protocol"].integrity = "sha512-acyE9ozxkMiWiz/xyWpU0O9vwnYv0hyG889Vniv6Sg9c9zfsX+8MePnDNphBacY2Fvm1rxdsGmiVDSZl9yuDFA==" |
            .packages["node_modules/@earendil-works/pi-telemetry"].integrity = "sha512-8e2CuxM+ht+hedQXTZmi5JVl6/xDK9RpSDL2+MbITevKYQhMZ/z6lJOTFgox3HQyGxO8mOZEtYGVeQNaD4OzqA==" |
            .packages["node_modules/@earendil-works/pi-tui"].integrity = "sha512-nPUnwDkLtupPXnZQYrCwPFcuTydCDqTY6ZbFqhsL4S4kVq0AT418kPa/6uXwtaCD+MjBNBltb7ScTYX65yeE1w=="
          ' npm-shrinkwrap.json > package-lock.json
          cp package-lock.json npm-shrinkwrap.json

          ${lib.getExe pkgs.jq} 'del(.devDependencies)' package.json > package.json.tmp
          mv package.json.tmp package.json
        '';

        npmDepsHash = "sha256-qehCRHtAPu1TS6zDPA5UgJ1ScUuRX3CmZhRoIQd3HM0=";

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
        pkgs.carapace
        pkgs.starship
        pkgs.zellij
        pkgs.neovim

        pkgs.zoxide
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
        pkgs.less
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
        pkgs.nmap
        pkgs.mtr

        pkgs.tldr
        pkgs.llm
        pkgs.codex
        pkgs.claude-code
        pi
        pkgs.television
        pkgs.pfetch-rs
        pkgs.tokei
        pkgs.cloc
        pkgs.glow
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
        pkgs.ninja
        pkgs.libtool
        pkgs.sccache
        pkgs.sqlite
        pkgs.gnutls
        pkgs.zstd
        pkgs.temurin-bin-25
        gradle
      ];
    };
}
