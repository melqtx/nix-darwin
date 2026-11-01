{
  description = "prometheus darwin config";

  nixConfig.extra-experimental-features = [
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
    nix-homebrew.inputs.brew-src.follows = "homebrew-brew";

    # Match the newer formula DSL used by the pinned Homebrew taps.
    homebrew-brew = {
      url = "github:Homebrew/brew/7.0.11";
      flake = false;
    };

    homebrew-core = {
      url = "github:Homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:Homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-anomalyco = {
      url = "github:anomalyco/homebrew-tap";
      flake = false;
    };
    homebrew-crmne = {
      url = "github:crmne/homebrew-tap";
      flake = false;
    };
    homebrew-cmux = {
      url = "github:manaflow-ai/homebrew-cmux";
      flake = false;
    };
    homebrew-qmk = {
      url = "github:qmk/homebrew-qmk";
      flake = false;
    };
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

        imports = filter (hasSuffix ".mod.nix") <| listFilesRecursive ./.;
      }
    );
}
