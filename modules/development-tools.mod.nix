{ ... }:

{
  flake.darwinModules.development-tools =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        pkgs.ast-grep
        pkgs.llm
        pkgs.codex
        pkgs.tokei
        pkgs.cloc
        pkgs.hyperfine
        pkgs.watchexec
        pkgs.just
        pkgs.difftastic
        pkgs.xh
        pkgs.shellcheck
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
        pkgs.gnutls
      ];
    };
}
