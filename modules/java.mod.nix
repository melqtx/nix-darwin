{ ... }:

{
  flake.darwinModules.java =
    { pkgs, ... }:
    let
      inherit (import ../templates/java/toolchain.nix { inherit pkgs; }) jdk gradle;
    in
    {
      environment.variables.JAVA_HOME = "${jdk}";

      environment.systemPackages = [
        jdk
        gradle
      ];
    };
}
