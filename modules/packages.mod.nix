{ config, ... }:

{
  flake.darwinModules.packages = {
    imports = [
      config.flake.darwinModules.cli-tools
      config.flake.darwinModules.data-tools
      config.flake.darwinModules.development-tools
      config.flake.darwinModules.java
      config.flake.darwinModules.monitoring-tools
      config.flake.darwinModules.nix-tools
    ];

  };
}
