{ pkgs }:

let
  toolchain = import ./toolchain.nix { inherit pkgs; };
in
pkgs.mkShell {
  packages = [
    toolchain.jdk
    toolchain.gradle
  ];
  JAVA_HOME = "${toolchain.jdk}";
}
