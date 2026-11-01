{ lib, moduleLocation, ... }:

let
  inherit (lib.options) mkOption;
  inherit (lib.attrsets) mapAttrs;
  inherit (lib.lists) singleton;
  inherit (lib.types) deferredModule lazyAttrsOf;

  modulesOf =
    class:
    mapAttrs (
      name: module: {
        _file = "${moduleLocation}#${class}.${name}";
        key = "${moduleLocation}#${class}.${name}";
        _class = class;
        imports = singleton module;
      }
    );
in
{
  options.flake.darwinModules = mkOption {
    type = lazyAttrsOf deferredModule;
    default = { };
    apply = modulesOf "darwin";
  };

  options.flake.homeModules = mkOption {
    type = lazyAttrsOf deferredModule;
    default = { };
    apply = modulesOf "homeManager";
  };
}
