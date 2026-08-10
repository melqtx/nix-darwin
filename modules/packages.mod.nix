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
        version = "0.84.1";

        src = pkgs.fetchurl {
          url = "https://registry.npmjs.org/@earendil-works/pi-coding-agent/-/pi-coding-agent-${finalAttrs.version}.tgz";
          hash = "sha256-ppoYWWAX6RlV/Q/Wd75p+rW26gHVsGIHvO407hUivCA=";
        };

        # the published shrinkwrap lacks integrity for pi's own sibling
        # packages, and devDependencies are absent from it entirely
        postPatch = ''
          ${lib.getExe pkgs.jq} '
            .packages["node_modules/@earendil-works/pi-agent-core"].integrity = "sha512-evyzXYWCLQGmcaBYHlmSku02r8qoN4SGI60GZABo6iV+H+nqX+P9ud8fEZ4GmRq9mUSREvvfX+w9dA9ThF9C6w==" |
            .packages["node_modules/@earendil-works/pi-ai"].integrity = "sha512-wMsAdJMxuNri08vLqTyYVI201DQQezGhPSTkzYsHdw5dYX3rCNwEmSvpaAwhi7ELKI/2tE/CEgSWg/6iRxSgdQ==" |
            .packages["node_modules/@earendil-works/pi-client"].integrity = "sha512-/V5hGHE4Zq+jG0GtwIB9PyBUOGd6gBLZ7lkQYFKchKnxYHeH3rmWC5xw4kpnZKKBuBuFTdLVbU9vEjlAGMMb2A==" |
            .packages["node_modules/@earendil-works/pi-protocol"].integrity = "sha512-Ox1pciyeSPGEEUcxvR0/dJcrY7C6hrEGA8y71rOsvSIUlXN1Cbp/be/eoL71OGDBk5O97TeQPfWN6Ju/2Ehjww==" |
            .packages["node_modules/@earendil-works/pi-telemetry"].integrity = "sha512-180/xGJtsq7IoR3p9EKWjRd0e9M4DkxInhlo9xyD7prDC7Qrhqq+nhvwrW0lFjPfXcEI2FSHmGCSyvSJE9GsaQ==" |
            .packages["node_modules/@earendil-works/pi-tui"].integrity = "sha512-udeXFbgEhJ6JiB0uguwNVNkDy2FENfmtQwPcY+/iJ8GWeq18wkal1tKqa5YyeH0IqtX1vG0cGh8zfSYzyzVuLA=="
          ' npm-shrinkwrap.json > package-lock.json
          cp package-lock.json npm-shrinkwrap.json

          ${lib.getExe pkgs.jq} 'del(.devDependencies)' package.json > package.json.tmp
          mv package.json.tmp package.json
        '';

        npmDepsHash = "sha256-FfwODI+m5Jts0PrjA9mFa+Mp9QT17/ejixg84RGXGe4=";

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
