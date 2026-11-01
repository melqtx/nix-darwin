{ config, lib, ... }:

let
  inherit (lib.attrsets) mapAttrs;
  environments = {
    rust = ./templates/rust;
    java = ./templates/java;
    web = ./templates/web;
    university = ./templates/university;
    databases = ./templates/databases;
  };
in
{
  flake.templates =
    (mapAttrs (name: path: {
      inherit path;
      description = "${name} development environment";
    }) environments)
    // {
      default = config.flake.templates.university;
    };

  perSystem = { pkgs, ... }: {
    devShells = (mapAttrs (_: path: import (path + /shell.nix) { inherit pkgs; }) environments) // {
      default = import ./templates/university/shell.nix { inherit pkgs; };
      stack = import ./templates/university/shell.nix { inherit pkgs; };
    };
  };
}
