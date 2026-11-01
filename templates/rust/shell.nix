{ pkgs }:

pkgs.mkShell {
  packages = [
    pkgs.cargo
    pkgs.rustc
    pkgs.clippy
    pkgs.rustfmt
    pkgs.rust-analyzer
    pkgs.cargo-nextest
    pkgs.cargo-deny
    pkgs.cargo-expand
    pkgs.lldb
    pkgs.pkg-config
  ];
  buildInputs = [
    pkgs.openssl
  ]
  ++ pkgs.lib.optionals pkgs.stdenv.hostPlatform.isDarwin [ pkgs.libiconv ];
  RUST_SRC_PATH = pkgs.rustPlatform.rustLibSrc;
}
