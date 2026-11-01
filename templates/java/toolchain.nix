{ pkgs }:

let
  jdk = pkgs.temurin-bin-25;
in
{
  inherit jdk;
  gradle = pkgs.gradle.override {
    gradle-unwrapped = pkgs.gradle-unwrapped.override {
      java = jdk;
      javaToolchains = [ jdk ];
    };
  };
}
