{ inputs, ... }:

{
  flake.homeModules.pi =
    { pkgs, ... }:
    let
      inherit (inputs.self.packages.${pkgs.stdenv.hostPlatform.system})
        pi-coding-agent
        sync-pi-setup
        ;
    in
    {
      # Syncing external sources and running npm are intentionally explicit;
      # a system rebuild must remain local and deterministic.
      home.packages = [
        pi-coding-agent
        sync-pi-setup
      ];
    };
}
