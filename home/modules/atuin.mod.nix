{ ... }:

{
  flake.homeModules.atuin = {
    programs.atuin = {
      enable = true;
      # The previous local TOML is backed up before taking ownership. This
      # replaces only config, never history, encryption keys or credentials.
      forceOverwriteSettings = true;
      # Fish initializes Atuin after fzf so Ctrl+R has a single owner.
      enableFishIntegration = false;
      settings = {
        update_check = false;
        secrets_filter = true;
        enter_accept = true;
        sync.records = true;
      };
    };
  };
}
