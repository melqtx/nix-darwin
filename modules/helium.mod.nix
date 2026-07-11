{ inputs, lib, ... }:

let
  inherit (lib.attrsets)
    attrNames
    concatMapAttrs
    filterAttrs
    getAttr
    hasAttr
    optionalAttrs
    ;
  inherit (lib.lists)
    filter
    foldr
    singleton
    ;
  inherit (lib.trivial)
    const
    importJSON
    warn
    flip
    ;
  inherit (lib.fixedPoints) fix;
  inherit (lib.strings) hasInfix;

  extensions.consent-o-matic.id = "mdjildafknihdffpkfmmpnpoiajfjnjd";
  extensions.ublock-origin =
    let
      assets = importJSON "${inputs.ublock}/assets/assets.json";

      filterLists =
        (
          assets
          |> filterAttrs (_: spec: (spec.content or null) == "filters" && (spec.group or null) != "regions")
          |> flip removeAttrs [
            "ublock-experimental"
          ]
          |> attrNames
        )
        ++ [
          "TUR-0"
          "user-filters"

          "https://raw.githubusercontent.com/DandelionSprout/adfilt/refs/heads/master/BrowseWebsitesWithoutLoggingIn.txt"
          "https://raw.githubusercontent.com/DandelionSprout/adfilt/refs/heads/master/ClearURLs%20for%20uBo/clear_urls_uboified.txt"
          "https://raw.githubusercontent.com/DandelionSprout/adfilt/refs/heads/master/LegitimateURLShortener.txt"
          "https://raw.githubusercontent.com/yokoffing/filterlists/refs/heads/main/annoyance_list.txt"
          "https://raw.githubusercontent.com/yokoffing/filterlists/refs/heads/main/click2load.txt"
          "https://raw.githubusercontent.com/yokoffing/filterlists/refs/heads/main/privacy_essentials.txt"
        ];

      filters = [
        # youtube shorts -> watch
        ''||youtube.com/shorts/$document,uritransform=/^https:\/\/(?:www\.|m\.)?youtube\.com\/shorts\/([^\/?#]+)/https:\/\/www.youtube.com\/watch?v=\$1/''

        # TODO: Allow youtube embeds without click2load'ing, as they are broken: https://github.com/uBlockOrigin/uBlock-issues/issues/3868
        "@@||youtube.com/embed/$frame"
        "@@||youtube-nocookie.com/embed/$frame"

        # old reddit
        "@@||reddit.com/media$document"
        "@@||reddit.com/mod$document"
        "@@||reddit.com/poll$document"
        "@@||reddit.com/settings$document"
        "@@||reddit.com/topics$document"
        "@@||reddit.com/community-points$document"
        "@@||reddit.com/appeal$document"
        "@@||reddit.com/appeals$document"
        "@@||reddit.com/notifications$document"
        "@@||reddit.com/message/compose/$document"
        "@@||reddit.com/mail^$document"
        "@@||reddit.com/answers^$document"
        "@@||reddit.com/r/subreddit^$document"
        ''@@/^https:\/\/\w*\.?reddit\.com\/r\/[A-Za-z0-9_]+\/s\//$document''
        ''@@/^https:\/\/\w*\.?reddit\.com\/.*[?&]new_reddit=true(?:$|[&#])/$document''

        ''||reddit.com/gallery/$document,uritransform=/^https:\/\/(?:www\.|np\.|amp\.|i\.)?reddit\.com\/gallery\/(.*)/https:\/\/old.reddit.com\/comments\/\$1/''
        ''||reddit.com^$document,uritransform=/^https:\/\/(?:www\.|np\.|amp\.|i\.)?reddit\.com\/(?!gallery\/)/https:\/\/old.reddit.com\//''

        "old.reddit.com##:is(#eu-cookie-policy, #redesign-beta-optin-btn)"
      ];
    in
    {
      id = "blockjmkbacgjkknlgpkjjiijinjdanf";
      preinstalled = true;

      settings.toolbar_pin = "force_pinned";

      policy = {
        toOverwrite.filterLists =
          filter (name: !(hasInfix "://" name || name == "user-filters" || hasAttr name assets)) filterLists
          |> foldr (name: warn "helium: unknown ublock filter list: ${name}") filterLists;

        toOverwrite.filters = filters;

        userSettings = [
          [
            "userFiltersTrusted"
            "true"
          ]
        ];
      };
    };

  # youtube
  extensions.dearrow.id = "enamippconapkdmgfgjchkhakpfinmaj";
  extensions.sponsorblock.id = "mnjggcdmjocbbbhaepdhchncahnbgone";

  # visuals
  extensions.dark-reader.id = "eimadpbcbfnmbkopoojfekhnkhdbieeh";
  extensions.refined-github.id = "hlepfoohegkhhmjieoechaddaejaokhf";

  # navigation
  extensions.violentmonkey.id = "jinjaccalgkegednnccohejagnlnfdag";
  extensions.vimium-c.id = "hfjbmagddngcpeloejdejnfgbamkjaeg";

  # services
  extensions.kagi.id = "cdglnehniifkbagbbombnjghhcihifij";
  extensions.keepassxc-browser = {
    id = "oboonakemofpalcgghocfoadofidjkkk";

    settings.toolbar_pin = "force_pinned";

    policy.settings = fix (settings: {
      autoFillRelevantCredential = true;

      defaultGroup = "Web";
      defaultPasskeyGroup = settings.defaultGroup;

      downloadFaviconAfterSave = true;
      passkeys = true;

      useCompactMode = true;
      useMonochromeToolbarIcon = true;
      usePasswordGeneratorIcons = true;
    });
  };

  policy = {
    # extensions
    ExtensionInstallBlocklist = singleton "*";

    ExtensionInstallAllowlist = policy.ExtensionInstallForcelist;
    ExtensionInstallForcelist =
      extensions
      |> filterAttrs (_: extension: !(extension.preinstalled or false))
      |> lib.mapAttrsToList (const <| getAttr "id");

    ExtensionInstallSources = singleton "https://services.helium.imput.net/*";

    ExtensionSettings =
      extensions
      |> concatMapAttrs (
        _: extension: optionalAttrs (extension ? settings) { ${extension.id} = extension.settings; }
      );

    "3rdparty".extensions =
      extensions
      |> concatMapAttrs (
        _: extension: optionalAttrs (extension ? policy) { ${extension.id} = extension.policy; }
      );

    # misc
    DefaultBrowserSettingEnabled = false;

    DeveloperToolsAvailability = 1;

    BatterySaverModeAvailability = 0;

    # "Continue where you left off" can't be set declaratively: the preference
    # is HMAC-tracked and the RestoreOnStartup policy is ignored on consumer
    # (non-MDM-enrolled) machines. Toggle it manually in settings once.

    # bookmarks
    ManagedBookmarks =
      let
        mkFolder = name: children: { inherit name children; };

        mkBookmark = name: url: { inherit name url; };

        mkScriptlet =
          name: javascript:
          mkBookmark name (
            "javascript:"
            + "{${javascript}}"
            +
              # javascript
              ''
                void undefined;
              ''
          );
      in
      [
        { toplevel_name = "Tools"; }

        (mkFolder "Archive" [
          (mkFolder "Wayback" [
            (mkScriptlet "View" # javascript
              ''
                window.open("https://web.archive.org/web/*/" + location.href);
              ''
            )
            (mkScriptlet "Save" # javascript
              ''
                window.open("https://web.archive.org/save/" + location.href);
              ''
            )
          ])
          (mkFolder "Archive.is" [
            (mkScriptlet "View" # javascript
              ''
                window.open("https://archive.ph/newest/" + location.href);
              ''
            )
            (mkScriptlet "Save" # javascript
              ''
                window.open("https://archive.ph/?run=1&url=" + encodeURIComponent(location.href));
              ''
            )
          ])
        ])

        (mkFolder "Reverse Image" (
          let
            mkReverse =
              name: prefix:
              mkScriptlet name # javascript
                ''
                  document.addEventListener("click", function handler(event) {
                    let image = event.target.closest("img");
                    if (!image) return;

                    event.preventDefault();
                    event.stopPropagation();
                    document.removeEventListener("click", handler, true);

                    window.open("${prefix}" + encodeURIComponent(image.src));
                  }, true);
                '';
          in
          [
            (mkReverse "Yandex" "https://yandex.com/images/search?rpt=imageview&url=")
            (mkReverse "Google Lens" "https://lens.google.com/uploadbyurl?url=")
            (mkReverse "Bing" "https://www.bing.com/images/search?view=detailv2&iss=sbi&q=imgurl:")
            (mkReverse "TinEye" "https://www.tineye.com/search?url=")
          ]
        ))

        (mkFolder "Nuke" [
          (mkScriptlet "Sticky Elements" # javascript
            ''
              document.querySelectorAll("body *").forEach((element) => {
                let position = getComputedStyle(element).position;
                if (position === "fixed" || position === "sticky") element.parentNode.removeChild(element);
              });

              document.documentElement.style.overflow = "auto";
              document.body.style.overflow = "auto";
            ''
          )

          (mkScriptlet "Copy Paste Restrictions" # javascript
            ''
              ["copy", "cut", "paste", "selectstart", "contextmenu", "dragstart"].forEach((eventName) => {
                document.addEventListener(eventName, (event) => event.stopPropagation(), true);
              });

              document.querySelectorAll("*").forEach((element) => {
                element.style.userSelect = "auto";
                element.style.webkitUserSelect = "auto";
              });
            ''
          )
        ])

        (mkFolder "Toggle" (
          let
            mkIndication =
              text: # javascript
              ''
                let indication = document.body.appendChild(document.createElement("div"));
                indication.textContent = ${text};

                Object.assign(indication.style, {
                  position: "fixed",
                  top: "0",
                  left: "0",

                  zIndex: "calc(infinity)",

                  padding: "8px 16px",
                  borderRadius: "8px",

                  colorScheme: "light dark",
                  background: "Canvas",
                  color: "CanvasText",
                  font: "14px/1 system-ui",

                  pointerEvents: "none",
                });

                indication.animate(
                  [
                    { opacity: 1, offset: 0.6, easing: "cubic-bezier(0.4, 0, 0.2, 1)" },
                    { opacity: 0, offset: 1 },
                  ],
                  { duration: 1500, fill: "forwards" },
                )
                .finished
                .then(() => indication.remove());
              '';
          in
          [
            (mkScriptlet "Password Inputs" # javascript
              ''
                let shown = false;

                document.querySelectorAll("input").forEach((input) => {
                  if (input.type === "password") {
                    input.dataset.wasPassword = "";
                    input.type = "text";
                    shown = true;
                  } else if ("wasPassword" in input.dataset) {
                    delete input.dataset.wasPassword;
                    input.type = "password";
                  }
                });

                ${mkIndication ''"Passwords " + (shown ? "shown" : "hidden")''}
              ''
            )

            (mkScriptlet "Design Mode" # javascript
              ''
                document.designMode = document.designMode === "on" ? "off" : "on";

                ${mkIndication ''"Design mode " + document.designMode''}
              ''
            )

            (mkScriptlet "Selections" # javascript
              ''
                let enabler = (window.__forceSelection ??= Object.assign(document.createElement("style"), {
                  textContent: `
                    *, *::before, *::after { user-select: text !important; }
                    [data-force-selection-before]::before { content: none !important; }
                    [data-force-selection-after]::after { content: none !important; }
                  `,
                  stop: (event) => event.stopPropagation(),
                }));

                if (!enabler.isConnected) {
                  document.head.appendChild(enabler);

                  ["copy", "cut", "paste", "selectstart", "contextmenu", "dragstart"].forEach((eventName) => {
                    document.addEventListener(eventName, enabler.stop, true);
                  });

                  /* Generated content (::before/::after) is unselectable,
                     so replace it with real text nodes and suppress the originals. */
                  document.querySelectorAll("*").forEach((element) => {
                    [
                      ["::before", "data-force-selection-before", "afterbegin"],
                      ["::after", "data-force-selection-after", "beforeend"],
                    ].forEach(([pseudo, attribute, position]) => {
                      let content = getComputedStyle(element, pseudo).content.match(/^"(.*)"$/s)?.[1];
                      if (content == null) return;

                      element.setAttribute(attribute, "");
                      element.insertAdjacentElement(position, Object.assign(document.createElement("span"), {
                        className: "force-selection-pseudo",
                        textContent: content,
                      }));
                    });
                  });
                } else {
                  enabler.remove();

                  ["copy", "cut", "paste", "selectstart", "contextmenu", "dragstart"].forEach((eventName) => {
                    document.removeEventListener(eventName, enabler.stop, true);
                  });

                  document.querySelectorAll(".force-selection-pseudo").forEach((span) => span.remove());
                  document.querySelectorAll("[data-force-selection-before], [data-force-selection-after]").forEach((element) => {
                    element.removeAttribute("data-force-selection-before");
                    element.removeAttribute("data-force-selection-after");
                  });
                }

                ${mkIndication ''"Selections " + (enabler.isConnected ? "enabled" : "disabled")''}
              ''
            )
          ]
        ))
      ];
  };
in
{
  flake.darwinModules.helium =
    { pkgs, ... }:
    let
      inherit (lib.generators) toPlist;
      inherit (lib.meta) getExe;
      inherit (lib.modules) mkAfter;
      inherit (lib.strings) concatLines;

      # Chromium on macOS reads main policy from net.imput.helium.plist and
      # per-extension ("3rdparty") policy from one plist per extension id.
      plists = {
        "net.imput.helium.plist" = policy |> toPlist { escape = true; };
      }
      // (
        policy."3rdparty".extensions
        |> concatMapAttrs (
          id: extensionPolicy: {
            "net.imput.helium.extensions.${id}.plist" = extensionPolicy |> toPlist { escape = true; };
          }
        )
      );

      installPlists =
        plists
        |> lib.mapAttrsToList (
          name: text:
          ''/usr/bin/install -m 644 -o root -g wheel "${pkgs.writeText name text}" "/Library/Managed Preferences/${name}"''
        )
        |> concatLines;
    in
    {
      system.activationScripts.postActivation.text = mkAfter ''
        # helium: managed policies
        /bin/mkdir -p "/Library/Managed Preferences"
        ${installPlists}

        # helium: assert default browser as the console user (macOS shows a
        # one-click confirmation dialog whenever the default actually changes)
        consoleUser=$(/usr/bin/stat -f %Su /dev/console)
        /usr/bin/sudo --set-home --user "$consoleUser" "${getExe pkgs.defaultbrowser}" helium || true
      '';
    };
}
