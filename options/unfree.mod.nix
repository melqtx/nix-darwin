{ ... }:

{
  flake.darwinModules.unfree = { config, lib, ... }: {
    options.nixpkgs.allowedUnfreePackages = lib.options.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };

    config.nixpkgs.config.allowUnfreePredicate =
      package: lib.lists.elem (lib.strings.getName package) config.nixpkgs.allowedUnfreePackages;
  };
}
