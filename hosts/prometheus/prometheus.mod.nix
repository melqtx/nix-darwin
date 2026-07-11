{ config, inputs, ... }:

{
  flake.darwinConfigurations.prometheus = inputs.nix-darwin.lib.darwinSystem {
    system = "aarch64-darwin";

    modules = [
      inputs.home-manager.darwinModules.home-manager
      inputs.nix-homebrew.darwinModules.nix-homebrew

      config.flake.darwinModules.darwin-defaults
      config.flake.darwinModules.helium
      config.flake.darwinModules.homebrew
      config.flake.darwinModules.packages

      (
        { ... }:
        {
          nix.enable = false;

          programs.fish.enable = true;

          users.users.melqtx = {
            name = "melqtx";
            home = "/Users/melqtx";
          };

          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;

            users.melqtx = config.flake.homeModules.melqtx;
          };

          system.primaryUser = "melqtx";
          system.stateVersion = 6;
        }
      )
    ];

    specialArgs = { inherit inputs; };
  };
}
