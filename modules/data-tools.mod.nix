{ ... }:

{
  flake.darwinModules.data-tools =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        pkgs.jq
        pkgs.yq
        pkgs.gron
        pkgs.jnv
        pkgs.jless
        pkgs.miller
        pkgs.sd
        pkgs.hexyl
        pkgs.pandoc
        pkgs.sqlite
        pkgs.postgresql
        pkgs.redis
        pkgs.duckdb
      ];
    };
}
