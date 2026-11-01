{ pkgs }:

let
  jdk = pkgs.temurin-bin-25;
  gradle = pkgs.gradle.override {
    gradle-unwrapped = pkgs.gradle-unwrapped.override {
      java = jdk;
      javaToolchains = [ jdk ];
    };
  };
in
pkgs.mkShell {
  packages = [
    jdk
    gradle
    pkgs.python3
    pkgs.uv
    pkgs.go
    pkgs.ghc
    pkgs.cabal-install
    pkgs.zig
    pkgs.lean4
    pkgs.cargo
    pkgs.rustc
    pkgs.clippy
    pkgs.rustfmt
    pkgs.rust-analyzer
    pkgs.nodejs_24
    pkgs.typescript
    pkgs.pnpm
    pkgs.clang
    pkgs.cmake
    pkgs.gnumake
    pkgs.sqlite
    pkgs.postgresql
    pkgs.redis
    pkgs.duckdb
  ];
  JAVA_HOME = "${jdk}";
  RUST_SRC_PATH = pkgs.rustPlatform.rustLibSrc;
}
