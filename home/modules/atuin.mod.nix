{ ... }:

{
  flake.homeModules.atuin =
    { lib, ... }:
    let
      inherit (lib.lists) singleton;
    in
    {
      programs.atuin = {
        enable = true;
        # The previous local TOML is backed up before taking ownership. This
        # replaces only config, never history, encryption keys or credentials.
        forceOverwriteSettings = true;
        enableFishIntegration = true;
        flags = singleton "--disable-ai";
        settings = {
          update_check = false;
          secrets_filter = true;
          enter_accept = true;
          sync.records = true;
        };
      };
    };
}
