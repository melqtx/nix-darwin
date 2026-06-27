{ lib, ... }:

let
  inherit (lib.options) mkOption;
  inherit (lib.types) lazyAttrsOf raw;
in
{
  options.flake.darwinModules = mkOption {
    type = lazyAttrsOf raw;
    default = { };
  };

  options.flake.homeModules = mkOption {
    type = lazyAttrsOf raw;
    default = { };
  };
}
