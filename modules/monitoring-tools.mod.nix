{ ... }:

{
  flake.darwinModules.monitoring-tools =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        pkgs.dua
        pkgs.dust
        pkgs.procs
        pkgs.ncdu
        pkgs.btop
        pkgs.bottom
        pkgs.bandwhich
        pkgs.nmap
        pkgs.mtr
        pkgs.pfetch-rs
        pkgs.fastfetch
      ];
    };
}
