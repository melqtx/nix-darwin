{
  config,
  inputs,
  ...
}:

let
  inherit (config) profile;
in
{
  flake.darwinConfigurations.prometheus = inputs.nix-darwin.lib.darwinSystem {
    system = "aarch64-darwin";

    modules = [
      config.flake.darwinModules.home-manager
      config.flake.darwinModules.unfree

      config.flake.darwinModules.darwin-defaults
      config.flake.darwinModules.fonts
      config.flake.darwinModules.helium
      config.flake.darwinModules.zen
      config.flake.darwinModules.homebrew
      config.flake.darwinModules.obs
      config.flake.darwinModules.rex
      config.flake.darwinModules.zed
      config.flake.darwinModules.hammerspoon
      config.flake.darwinModules.vesktop
      config.flake.darwinModules.claude-code
      config.flake.darwinModules.packages

      {
        nix.enable = false;

        programs.fish.enable = true;

        users.users.${profile.username} = {
          name = profile.username;
          home = profile.homeDirectory;
        };

        system.primaryUser = profile.username;
        system.stateVersion = 6;
      }
    ];
  };
}
