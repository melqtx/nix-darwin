{ config, ... }:

let
  inherit (config) profile;
in

{
  flake.homeModules.melqtx = {
    imports = [
      config.flake.homeModules.fish
      config.flake.homeModules.nushell
      config.flake.homeModules.atuin
      config.flake.homeModules.starship
      config.flake.homeModules.tooling
      config.flake.homeModules.helix
      config.flake.homeModules.neovim
      config.flake.homeModules.version-control
      config.flake.homeModules.pi
      config.flake.homeModules.language-tools
      config.flake.homeModules.emacs
      config.flake.homeModules.syncthing
      config.flake.homeModules.nix
    ];

    home.username = profile.username;

    home.homeDirectory = profile.homeDirectory;

    home.stateVersion = "26.05";

    programs.home-manager.enable = true;
  };
}
