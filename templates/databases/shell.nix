{ pkgs }:

pkgs.mkShell {
  packages = [
    pkgs.postgresql
    pkgs.redis
    pkgs.sqlite
    pkgs.duckdb
  ];
}
