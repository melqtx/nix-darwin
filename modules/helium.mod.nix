{ ... }:

{
  flake.darwinModules.helium =
    { lib, pkgs, ... }:
    let
      inherit (lib.attrsets) mapAttrsToList;
      inherit (lib.meta) getExe;
      inherit (lib.modules) mkAfter;
      inherit (lib.strings) concatLines toJSON;

      # Helium itself comes from the homebrew cask. Managed policies were
      # tried and dropped: any Chromium policy permanently brands the browser
      # "managed by your organization". Extensions are instead seeded through
      # Chromium's "external extensions" mechanism, which installs from the
      # web store without marking the browser managed; Helium prompts once
      # per extension to enable it.
      extensions = {
        # ublock-origin ships preinstalled with helium
        dark-reader = "eimadpbcbfnmbkopoojfekhnkhdbieeh";
        old-reddit-redirect = "dneaehbmnbhcippjikoajpoabadpodje";
        refined-github = "hlepfoohegkhhmjieoechaddaejaokhf";
        sponsorblock = "mnjggcdmjocbbbhaepdhchncahnbgone";
        vimium-c = "hfjbmagddngcpeloejdejnfgbamkjaeg";
        violentmonkey = "jinjaccalgkegednnccohejagnlnfdag";
      };

      externalExtensionsDir = "/Library/Application Support/net.imput.helium/External Extensions";

      externalSpec = pkgs.writeText "helium-external-extension.json" (toJSON {
        external_update_url = "https://clients2.google.com/service/update2/crx";
      });

      installExtensions = concatLines (
        mapAttrsToList (
          _: id:
          ''/usr/bin/install -m 644 -o root -g wheel "${externalSpec}" "${externalExtensionsDir}/${id}.json"''
        ) extensions
      );
    in
    {
      system.activationScripts.postActivation.text = mkAfter ''
        # helium: purge leftover managed policies; the dropped policy module
        # left plists behind whose ExtensionInstallBlocklist=* kept blocking
        # every extension install (cfprefsd caches them, hence the killall)
        /bin/rm -f "/Library/Managed Preferences/net.imput.helium"*.plist
        /usr/bin/killall cfprefsd 2>/dev/null || true

        # helium: seed external extensions
        /bin/mkdir -p "${externalExtensionsDir}"
        ${installExtensions}

        # helium: assert default browser as the console user (macOS shows a
        # one-click confirmation dialog whenever the default actually changes)
        consoleUser=$(/usr/bin/stat -f %Su /dev/console)
        /usr/bin/sudo --set-home --user "$consoleUser" "${getExe pkgs.defaultbrowser}" helium || true
      '';
    };
}
