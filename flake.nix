{
  description = "prometheus darwin config";

  nixConfig.experimental-features = [
    "flakes"
    "nix-command"
    "pipe-operators"
  ];

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-doom-emacs-unstraightened = {
      url = "github:marienz/nix-doom-emacs-unstraightened";
      # The Home Manager module uses this flake's pkgs, not its own nixpkgs.
      inputs.nixpkgs.follows = "";
    };

    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    # Upstream now pins Brew 7, so the older cask-DSL override is unnecessary.
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } (
      { lib, ... }:
      let
        inherit (lib.filesystem) listFilesRecursive;
        inherit (lib.lists) filter singleton;
        inherit (lib.strings) hasSuffix;
      in
      {
        systems = singleton "aarch64-darwin";

        imports = filter (hasSuffix ".mod.nix") (listFilesRecursive ./.);
      }
    );
}
