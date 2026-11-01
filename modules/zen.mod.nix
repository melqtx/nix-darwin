{ self, ... }:

{
  flake.darwinModules.zen =
    { lib, ... }:
    let
      inherit (lib.attrsets) mapAttrs' nameValuePair;
      inherit (lib.lists) singleton;

      # Firefox IDs verified against addons.mozilla.org's API. The first five
      # match Helium's declarative set; uBlock is bundled only with Helium.
      # Proton Pass and DeArrow are already used in the existing Zen profile.
      extensions = {
        darkreader = "addon@darkreader.org";
        refined-github- = "{a4c4eda4-fb84-4a84-b4a1-f7c1cbf2a1ad}";
        sponsorblock = "sponsorBlocker@ajay.app";
        vimium-c = "vimium-c@gdh1995.cn";
        violentmonkey = "{aecec67f-0d10-4fa7-b7c7-609a2db280cf}";
        ublock-origin = "uBlock0@raymondhill.net";
        proton-pass = "78272b6fa58f4a1abaac99321d503a20@proton.me";
        dearrow = "deArrow@ajay.app";
      };
    in
    {
      imports = singleton self.darwinModules.homebrew;
      homebrew.casks = singleton "zen";

      # Use CFPreferences through nix-darwin's `defaults write`, not a
      # policies.json inside the signed Homebrew app bundle. Policies apply
      # to every Zen profile for the primary user without owning profiles.ini,
      # user.js, prefs.js, extension storage, or session/bookmark databases.
      # https://github.com/zen-browser/desktop/issues/12363
      system.defaults.CustomUserPreferences."app.zen-browser.zen" = {
        EnterprisePoliciesEnabled = true;

        # Unlike force_installed, normal_installed permits disabling add-ons.
        # No wildcard: extensions installed by hand remain allowed. AMO owns
        # updates, just as the web store does for Helium's extension seeds.
        ExtensionSettings = mapAttrs' (
          slug: id:
          nameValuePair id {
            installation_mode = "normal_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/${slug}/latest.xpi";
          }
        ) extensions;

        # Carry over the portable Helium defaults, without locking choices
        # made in Zen's UI. Zen already supplies its own vertical-tab layout.
        Preferences = {
          "browser.download.useDownloadDir" = {
            Value = false;
            Status = "default";
          };
          "browser.tabs.insertAfterCurrent" = {
            Value = true;
            Status = "default";
          };
        };
      };
    };
}
