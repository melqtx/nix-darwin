{ config, ... }:

{
  flake.homeModules.melqtx = {
    imports = [
      config.flake.homeModules.fish
      config.flake.homeModules.starship
      config.flake.homeModules.ghostty
      config.flake.homeModules.zellij
      config.flake.homeModules.helix
      config.flake.homeModules.version-control
      config.flake.homeModules.language-tools
    ];

    home.username = "melqtx";
    home.homeDirectory = "/Users/melqtx";
    home.stateVersion = "26.05";

    programs.home-manager.enable = true;
  };
}
