{ pkgs, ... }:

{
  imports = [
    ./modules/fish.nix
    ./modules/git.nix
    ./modules/starship.nix
    ./modules/ghostty.nix
    ./modules/zellij.nix
  ];

  home.username = "melqtx";
  home.homeDirectory = "/Users/melqtx";
  home.stateVersion = "26.05";

  programs.home-manager.enable = true;
}
