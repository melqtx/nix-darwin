{ ... }:

{
  flake.darwinModules.nix-tools =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        pkgs.nh
        pkgs.nvd
        pkgs.nix-output-monitor
        pkgs.statix
        pkgs.deadnix
        pkgs.comma
      ];
    };
}
