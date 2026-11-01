{ ... }:

{
  flake.homeModules.language-tools =
    { pkgs, ... }:
    {
      home.sessionVariables.RUST_SRC_PATH = "${pkgs.rustPlatform.rustLibSrc}";
      home.packages = [
        pkgs.nixd
        pkgs.nixfmt

        pkgs.cargo
        pkgs.rustc
        pkgs.rustfmt
        pkgs.rust-analyzer
        pkgs.clippy
        pkgs.lldb
        pkgs.rustlings

        pkgs.gofumpt
        pkgs.gopls
        pkgs.delve

        pkgs.ruff
        pkgs.ty
        pkgs.python3Packages.debugpy
        pkgs.python3

        pkgs.prettier
        pkgs.typescript-language-server
        pkgs.typescript
        pkgs.vscode-langservers-extracted
        pkgs.yaml-language-server
        pkgs.lua-language-server

        pkgs.haskellPackages.fourmolu
        pkgs.haskell-language-server
        pkgs.ghc
        pkgs.cabal-install

        pkgs.lean4

        pkgs.zig
        pkgs.zls

        pkgs.google-java-format
        pkgs.jdt-language-server
      ];
    };
}
