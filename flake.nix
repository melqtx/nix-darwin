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
    # nix-homebrew pins brew 6.0.1, but cask definitions come from the JSON API
    # and now use the `command_wrapper` stanza, added in brew 6.0.13. Without
    # this override every `brew bundle` fails to fetch any cask. Note the
    # derivation is still named brew-6.0.1-patched: nix-homebrew reads the
    # version string from its own flake.lock, so the name ignores this pin.
    nix-homebrew.inputs.brew-src.url = "github:Homebrew/brew/6.0.14";
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
