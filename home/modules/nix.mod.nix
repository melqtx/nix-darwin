{ inputs, ... }:

{
  flake.homeModules.nix = { pkgs, ... }: {
    home.packages = [
      (pkgs.writeShellApplication {
        name = "rebuild";
        runtimeInputs = [ pkgs.nh ];
        text = ''
          exec nh darwin switch "''${NH_FLAKE:-$HOME/dots}" "$@"
        '';
      })
      (pkgs.writeShellApplication {
        name = "check-dots";
        text = ''
          flake="''${NH_FLAKE:-$HOME/dots}"
          nix flake check --no-build --no-write-lock-file "$flake"
          nix build --no-link --no-write-lock-file \
            "$flake#checks.aarch64-darwin.lint"
        '';
      })
    ];
    nix.registry.nixpkgs.flake = inputs.nixpkgs;
    nix.nixPath = [ "nixpkgs=flake:nixpkgs" ];

    home.extraDependencies = [
      inputs.nixpkgs.outPath
      inputs.home-manager.outPath
      inputs.nix-darwin.outPath
      inputs.flake-parts.outPath
      inputs.nix-homebrew.outPath
      inputs.nix-doom-emacs-unstraightened.outPath
    ];
  };
}
