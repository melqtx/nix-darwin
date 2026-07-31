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

      security.sudo.extraConfig = ''
        Defaults lecture = never
        Defaults pwfeedback
      '';

      # Right cmd becomes F18, which hammerspoon treats as the Hyper layer.
      # Applies to all keyboards; the internal one has no right cmd, so it
      # only affects the HHKB in practice.
      system.keyboard = {
        enableKeyMapping = true;
        userKeyMapping = [
          {
            HIDKeyboardModifierMappingSrc = 30064771303; # 0x7000000E7 right cmd
            HIDKeyboardModifierMappingDst = 30064771181; # 0x70000006D F18
          }
        ];
      };

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

          "com.mitchellh.ghostty".NSUserKeyEquivalents = {
            "Hide Ghostty" = "@~^$h";
            "Hide Others" = "@~^$o";
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

      # screencapture silently falls back to the Desktop when its target does
      # not exist, so create it before defaults are applied.
      system.activationScripts.postActivation.text = mkAfter ''
        /usr/bin/install -d -o ${primaryUser} -g staff ${escapeShellArg config.system.defaults.screencapture.location}
        /usr/bin/chflags nohidden ${escapeShellArg userHome}/Library

        # Homebrew can replace app bundles during activation; refresh
        # LaunchServices so repaired Discord/Vesktop bundles are discoverable.
        lsregister=/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister
        for app in /Applications/Discord.app /Applications/Vesktop.app; do
          if [ -d "$app" ]; then
            "$lsregister" -f "$app"
          fi
        done
      '';
    };
}
