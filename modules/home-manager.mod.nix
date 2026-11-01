{ config, inputs, ... }:

let
  inherit (config) profile;
  homeModule = config.flake.homeModules.melqtx;
in
{
  flake.darwinModules.home-manager = {
    imports = [ inputs.home-manager.darwinModules.home-manager ];

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      users.${profile.username} = homeModule;
    };
  };
}
