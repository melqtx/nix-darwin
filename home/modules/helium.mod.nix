{ ... }:

{
  flake.homeModules.helium =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      inherit (lib.strings) toJSON;

      preferences = {
        helium.completed_onboarding = true;
        helium.services.user_consented = true;

        helium.browser.layout = 2; # vertical tabs
        helium.browser.rounded_frame = false;

        helium.browser.new_tab_next_to_active = true;

        bookmark_bar.show_on_all_tabs = true;
        bookmark_bar.show_tab_groups = false;

        download.prompt_for_download = true; # ask where to save each time

        # Per-extension incognito can't be managed: `extensions.settings` is
        # HMAC-tracked and writing it externally trips Chromium's reset popup.
        # Toggle manually in helium://extensions.
      };

      preferencesFile = pkgs.writeText "helium-default-preferences.json" (toJSON preferences);
    in
    {
      # Chromium rewrites Preferences constantly at runtime, so it can't be a
      # store symlink; seed it once and let the browser own it afterwards.
      home.activation.seedHeliumPreferences = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        prefs="${config.home.homeDirectory}/Library/Application Support/net.imput.helium/Default/Preferences"

        if [ ! -e "$prefs" ]; then
          $DRY_RUN_CMD /bin/mkdir -p "$(/usr/bin/dirname "$prefs")"
          $DRY_RUN_CMD /bin/cp "${preferencesFile}" "$prefs"
          $DRY_RUN_CMD /bin/chmod 600 "$prefs"
        fi
      '';
    };
}
