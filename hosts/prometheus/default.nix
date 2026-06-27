{ pkgs, ... }:

{
  imports = [
    ../../modules/packages.nix
    ../../modules/homebrew.nix
    ../../modules/macos.nix
  ];

  nix.enable = false;

  programs.fish.enable = true;

  users.users.melqtx = {
    name = "melqtx";
    home = "/Users/melqtx";
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    users.melqtx = import ../../home/melqtx.nix;
  };

  system.primaryUser = "melqtx";
  system.stateVersion = 6;
}
