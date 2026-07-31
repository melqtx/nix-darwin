{ ... }:

{
  flake.homeModules.vesktop =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      settingsFile = "${config.home.homeDirectory}/Library/Application Support/vesktop/settings/settings.json";
    in
    {
      # Homebrew owns the app bundle. Vesktop's self-updater can replace files
      # inside that bundle and leave macOS rejecting it as improperly signed.
      home.activation.disableVesktopAutoUpdate = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        settings=${lib.escapeShellArg settingsFile}
        if [ -f "$settings" ]; then
          tmp="$settings.codex-tmp"
          ${lib.getExe pkgs.jq} '.autoUpdate = false | .autoUpdateNotification = false' "$settings" > "$tmp"
          /bin/mv "$tmp" "$settings"
        fi
      '';
    };
}
