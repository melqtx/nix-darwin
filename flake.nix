{
  description = "prometheus macOS config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nixpkgs, nix-darwin, home-manager, ... }: {
    darwinConfigurations."prometheus" = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";

      modules = [
        ./hosts/prometheus
        home-manager.darwinModules.home-manager
      ];

      specialArgs = { inherit inputs; };
    };
  };
}
