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
        version = "0.82.0";

        src = pkgs.fetchurl {
          url = "https://registry.npmjs.org/@earendil-works/pi-coding-agent/-/pi-coding-agent-${finalAttrs.version}.tgz";
          hash = "sha256-qcnX+GGnUIr15RbUk6A+rB/vNvi1b7DSBNpkOVDl2wg=";
        };

        # the published shrinkwrap lacks integrity for pi's own sibling
        # packages, and devDependencies are absent from it entirely
        postPatch = ''
          ${lib.getExe pkgs.jq} '
            .packages["node_modules/@earendil-works/pi-agent-core"].integrity = "sha512-bnS9DpOKK5T/F/gQkaOnYdMsuuciWiScfAHHWC+k5OQ0HxjSqMFQvp8keurULLoT4+v8NHv4V14pNvd4hsfC0Q==" |
            .packages["node_modules/@earendil-works/pi-ai"].integrity = "sha512-8MvW9+zno13sXDuT2kFMnWeTNUufUhPeZDRVO+igGoBRCDWgn7Xh2FkRQI1mRuet6QhF4ENQuLYdIAOyG6BhNw==" |
            .packages["node_modules/@earendil-works/pi-tui"].integrity = "sha512-9IDjQOXne7t9l2s2YcjnIBxsVNVPE7qScVSB3YmFlXsBW4pfo2gOElTxggV84KrRiGqABnlFPBWbf0k54hszHQ=="
          ' npm-shrinkwrap.json > package-lock.json
          cp package-lock.json npm-shrinkwrap.json

          ${lib.getExe pkgs.jq} 'del(.devDependencies)' package.json > package.json.tmp
          mv package.json.tmp package.json
        '';

        npmDepsHash = "sha256-N/HHIn5dQKEeljD+3qod4TvfGFnI6wWFJ7Q3LIBoPXc=";

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
