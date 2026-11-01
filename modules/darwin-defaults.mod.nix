{ ... }:

{
  flake.darwinModules.darwin-defaults =
    { config, lib, ... }:
    let
      inherit (lib.modules) mkAfter;
      inherit (lib.strings) escapeShellArg;

      primaryUser = config.system.primaryUser;
      userHome = config.users.users.${primaryUser}.home;
    in
    {
      security.pam.services.sudo_local = {
        touchIdAuth = true;
        reattach = true;
      };

      security.sudo.extraConfig = /* sudoers */ ''
        Defaults lecture = never
        Defaults pwfeedback
      '';

      system.defaults = {
        dock = {
          autohide = true;
          autohide-delay = 0.05;
          autohide-time-modifier = 0.25;
          expose-animation-duration = 0.0;
          launchanim = false;
          # Stable Space ordering; macOS must not reshuffle workspaces by
          # recent use.
          mru-spaces = false;
          show-recents = false;
          showhidden = true;

          # HOT CORNERS OFF (1 = no action)
          wvous-bl-corner = 1;
          wvous-br-corner = 1;
          wvous-tl-corner = 1;
          wvous-tr-corner = 1;
        };

        finder = {
          AppleShowAllExtensions = true;
          AppleShowAllFiles = true;
          FXDefaultSearchScope = "SCcf";
          FXEnableExtensionChangeWarning = false;
          FXPreferredViewStyle = "Nlsv";
          FXRemoveOldTrashItems = true;
          NewWindowTarget = "Home";
          QuitMenuItem = true;
          ShowPathbar = true;
          ShowStatusBar = true;
          _FXShowPosixPathInTitle = true;
          _FXSortFoldersFirst = true;
        };

        NSGlobalDomain = {
          AppleICUForce24HourTime = true;
          AppleKeyboardUIMode = 3;
          AppleMeasurementUnits = "Centimeters";
          AppleMetricUnits = 1;
          ApplePressAndHoldEnabled = false;
          AppleScrollerPagingBehavior = true;
          # Cmd+Tab must follow the app to its Space; with this false the app
          # activates (menu bar changes) but the workspace never switches.
          AppleSpacesSwitchOnActivate = true;
          AppleTemperatureUnit = "Celsius";
          InitialKeyRepeat = 15;
          KeyRepeat = 2;
          NSAutomaticCapitalizationEnabled = false;
          NSAutomaticDashSubstitutionEnabled = false;
          NSAutomaticInlinePredictionEnabled = false;
          NSAutomaticPeriodSubstitutionEnabled = false;
          NSAutomaticQuoteSubstitutionEnabled = false;
          NSDocumentSaveNewDocumentsToCloud = false;
          NSNavPanelExpandedStateForSaveMode = true;
          NSWindowResizeTime = 0.003;
          NSWindowShouldDragOnGesture = true;
          PMPrintingExpandedStateForPrint = true;
        };

        # These are all per-user preference domains; written system-wide they
        # lose to the values already present in the user domain.
        CustomUserPreferences = {
          "com.apple.AdLib" = {
            allowApplePersonalizedAdvertising = false;
            allowIdentifierForAdvertising = false;
            forceLimitAdTracking = true;
            personalizedAdsMigrated = false;
          };

          "com.apple.desktopservices" = {
            DSDontWriteNetworkStores = true;
            DSDontWriteUSBStores = true;
          };

          "com.apple.finder" = {
            DisableAllAnimations = true;
            WarnOnEmptyTrash = false;
          };

        };

        screensaver = {
          askForPassword = true;
          askForPasswordDelay = 0;
        };

        controlcenter.BatteryShowPercentage = true;

        loginwindow = {
          DisableConsoleAccess = true;
          GuestEnabled = false;
        };

        menuExtraClock = {
          Show24Hour = true;
          ShowSeconds = false;
        };

        screencapture = {
          disable-shadow = true;
          location = "${userHome}/Pictures/screenshots";
          type = "png";
        };

        SoftwareUpdate.AutomaticallyInstallMacOSUpdates = false;
      };

      # Create the screenshot target and merge only the symbolic shortcuts we
      # own. A system.defaults dictionary assignment replaces every unrelated
      # macOS shortcut, while defaults -dict-add preserves the existing map.
      system.activationScripts.postActivation.text = mkAfter /* bash */ ''
        /usr/bin/install -d -o ${primaryUser} -g staff ${escapeShellArg config.system.defaults.screencapture.location}
        /usr/bin/chflags nohidden ${escapeShellArg userHome}/Library

        primary_uid=$(/usr/bin/id -u ${escapeShellArg primaryUser})
        run_as_primary_user() {
          /bin/launchctl asuser "$primary_uid" /usr/bin/sudo --user ${escapeShellArg primaryUser} "$@"
        }

        hotkeys_before="$(run_as_primary_user /usr/bin/defaults read com.apple.symbolichotkeys AppleSymbolicHotKeys 2>/dev/null || true)"

        # Raycast owns the launcher shortcut. Disable both Spotlight actions
        # on every rebuild without replacing other symbolic hotkeys.
        run_as_primary_user /usr/bin/defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys \
          -dict-add 64 '<dict><key>enabled</key><false/><key>value</key><dict><key>parameters</key><array><integer>32</integer><integer>49</integer><integer>1048576</integer></array><key>type</key><string>standard</string></dict></dict>' \
                    65 '<dict><key>enabled</key><false/><key>value</key><dict><key>parameters</key><array><integer>32</integer><integer>49</integer><integer>1572864</integer></array><key>type</key><string>standard</string></dict></dict>'
        run_as_primary_user /usr/bin/defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys \
          -dict-add 118 '{ enabled = true; value = { parameters = (65535, 18, 262144); type = standard; }; }'
        run_as_primary_user /usr/bin/defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys \
          -dict-add 119 '{ enabled = true; value = { parameters = (65535, 19, 262144); type = standard; }; }'
        run_as_primary_user /usr/bin/defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys \
          -dict-add 120 '{ enabled = true; value = { parameters = (65535, 20, 262144); type = standard; }; }'
        run_as_primary_user /usr/bin/defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys \
          -dict-add 121 '{ enabled = true; value = { parameters = (65535, 21, 262144); type = standard; }; }'
        run_as_primary_user /usr/bin/defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys \
          -dict-add 122 '{ enabled = true; value = { parameters = (65535, 23, 262144); type = standard; }; }'

        hotkeys_after="$(run_as_primary_user /usr/bin/defaults read com.apple.symbolichotkeys AppleSymbolicHotKeys 2>/dev/null || true)"
        if [ "$hotkeys_before" != "$hotkeys_after" ]; then
          # Reload shortcuts in the logged-in user's session, not just Dock.
          activate_settings=/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings
          if [ -x "$activate_settings" ]; then
            run_as_primary_user "$activate_settings" -u || echo "Shortcut reload failed; log out and back in to apply preferences." >&2
          fi
          run_as_primary_user /usr/bin/killall Dock 2>/dev/null || true
        fi
      '';
    };
}
