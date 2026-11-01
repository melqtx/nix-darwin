{ self, ... }:

{
  flake.darwinModules.helium =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      inherit (lib.attrsets) mapAttrsToList;
      inherit (lib.lists) singleton;
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
        refined-github = "hlepfoohegkhhmjieoechaddaejaokhf";
        sponsorblock = "mnjggcdmjocbbbhaepdhchncahnbgone";
        vimium-c = "hfjbmagddngcpeloejdejnfgbamkjaeg";
        violentmonkey = "jinjaccalgkegednnccohejagnlnfdag";
      };

      # Upstream Chromium hardcodes this exact path on macOS for every build
      # flavor (chrome/common/chrome_paths.cc, DIR_EXTERNAL_EXTENSIONS), and
      # neither helium nor ungoogled-chromium patches it -- so helium reads
      # external extensions from the "Google/Chrome" directory, and any real
      # Chrome install will see (and prompt about) these seeds too.
      externalExtensionsDir = "/Library/Application Support/Google/Chrome/External Extensions";

      # Must be helium's web-store proxy, not clients2.google.com directly:
      # helium strips prodversion from update queries (its downloader
      # platform-spoofing patch), and Google's endpoint answers "noupdate"
      # to any query without it. The proxy tolerates the stripped query and
      # serves the CWS crx through services.helium.imput.net/ext/proxy.
      externalSpec =
        pkgs.writeText "helium-external-extension.json"
        <| toJSON {
          external_update_url = "https://services.helium.imput.net/ext";
        };

      installExtensions = concatLines (
        mapAttrsToList (
          _: id:
          ''/usr/bin/install -m 644 -o root -g wheel "${externalSpec}" "${externalExtensionsDir}/${id}.json"''
        ) extensions
      );
    in
    {
      imports = [
        self.darwinModules.homebrew
        self.darwinModules.home-manager
      ];
      homebrew.casks = singleton "helium-browser";
      home-manager.users.${config.system.primaryUser}.imports = singleton self.homeModules.helium;

      system.activationScripts.postActivation.text = mkAfter /* bash */ ''
        # This directory is shared with Chrome; only install our own IDs.
        /bin/mkdir -p "${externalExtensionsDir}"
        ${installExtensions}
      '';
    };
}
