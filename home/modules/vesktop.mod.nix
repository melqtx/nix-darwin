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

        if [[ -v DRY_RUN ]]; then
          if [ -f "$settings" ]; then
            echo "Would disable Vesktop's self-updater in $settings"
          fi
        elif [ -f "$settings" ]; then
          tmp=$(/usr/bin/mktemp "$settings.home-manager.XXXXXX")

          if ! ${lib.getExe pkgs.jq} \
            '.autoUpdate = false | .autoUpdateNotification = false' \
            "$settings" > "$tmp"; then
            /bin/rm -f "$tmp"
            exit 1
          fi

          if /usr/bin/cmp -s "$tmp" "$settings"; then
            /bin/rm -f "$tmp"
          else
            mode=$(/usr/bin/stat -f '%Lp' "$settings")
            /bin/chmod "$mode" "$tmp"
            /bin/mv -f "$tmp" "$settings"
          fi
        fi
      '';
    };
}
