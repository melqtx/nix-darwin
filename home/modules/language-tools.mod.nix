{ ... }:

{
  flake.homeModules.language-tools =
    { pkgs, ... }:
    {
      home.packages = [
        pkgs.nixd
        pkgs.nixfmt

        pkgs.rustfmt
        pkgs.rust-analyzer
        pkgs.clippy
        pkgs.lldb

        pkgs.gofumpt
        pkgs.gopls
        pkgs.delve

        pkgs.ruff
        pkgs.ty
        pkgs.python3Packages.debugpy

        pkgs.prettier
        pkgs.typescript-language-server
        pkgs.vscode-langservers-extracted
        pkgs.yaml-language-server
        pkgs.lua-language-server

        pkgs.haskellPackages.fourmolu
        pkgs.haskell-language-server

        pkgs.zig
        pkgs.zls

        pkgs.google-java-format
        pkgs.jdt-language-server
      ];
    };
}
