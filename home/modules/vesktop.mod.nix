{ self, ... }:

{
  flake.darwinModules.vesktop = { config, lib, ... }: {
    imports = [
      self.darwinModules.homebrew
      self.darwinModules.home-manager
    ];
    homebrew.casks = lib.lists.singleton "vesktop";
    home-manager.users.${config.system.primaryUser}.imports =
      lib.lists.singleton self.homeModules.vesktop;
  };

  flake.homeModules.vesktop =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      inherit (lib.hm.dag) entryAfter;
      inherit (lib.lists) singleton;
      inherit (lib.meta) getExe;
      inherit (lib.strings) escapeShellArg;
    in
    {
      # Homebrew owns the app bundle. Vesktop's self-updater can replace files
      # inside that bundle and leave macOS rejecting it as improperly signed.
      home.activation.disableVesktopAutoUpdate = entryAfter (singleton "writeBoundary") /* bash */ ''
        settings=${escapeShellArg "${config.home.homeDirectory}/Library/Application Support/vesktop/settings/settings.json"}

        if [[ -v DRY_RUN ]]; then
          echo "Would disable Vesktop's self-updater in $settings"
        else
          /bin/mkdir -p "$(/usr/bin/dirname "$settings")"
          tmp=$(/usr/bin/mktemp "$settings.home-manager.XXXXXX")
          source=/dev/null
          if [ -f "$settings" ]; then
            source="$settings"
          fi

          # Slurp accepts an empty source on first installation, but reject
          # malformed or non-object settings rather than discarding user data.
          if ! ${getExe pkgs.jq} --slurp '
            (if length == 0 then {} elif length == 1 and (.[0] | type) == "object"
             then .[0] else error("Expected one Vesktop settings object") end)
            | .autoUpdate = false | .autoUpdateNotification = false
          ' "$source" > "$tmp"; then
            /bin/rm -f "$tmp"
            exit 1
          fi

          if [ -f "$settings" ] && /usr/bin/cmp -s "$tmp" "$settings"; then
            /bin/rm -f "$tmp"
          else
            mode=600
            if [ -f "$settings" ]; then
              mode=$(/usr/bin/stat -f '%Lp' "$settings")
            fi
            /bin/chmod "$mode" "$tmp"
            /bin/mv -f "$tmp" "$settings"
          fi
        fi
      '';
    };
}
