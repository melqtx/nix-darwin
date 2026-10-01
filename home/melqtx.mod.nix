{ config, ... }:

{
  flake.homeModules.melqtx = {
    imports = [
      config.flake.homeModules.fish
      config.flake.homeModules.atuin
      config.flake.homeModules.starship
      config.flake.homeModules.tooling
      config.flake.homeModules.ghostty
      config.flake.homeModules.zellij
      config.flake.homeModules.helix
      config.flake.homeModules.zed
      config.flake.homeModules.version-control
      config.flake.homeModules.claude-code
      config.flake.homeModules.pi
      config.flake.homeModules.language-tools
      config.flake.homeModules.emacs
      config.flake.homeModules.hammerspoon
      config.flake.homeModules.helium
      config.flake.homeModules.vesktop
    ];

    home.username = "melqtx";
    home.homeDirectory = "/Users/melqtx";
    home.stateVersion = "26.05";

    home.file."Library/Logs/Syncthing/.keep".text = "";

    programs.home-manager.enable = true;
    services.syncthing.enable = true;
  };
}
