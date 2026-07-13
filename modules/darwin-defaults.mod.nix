{ ... }:

{
  flake.darwinModules.darwin-defaults =
    { config, lib, ... }:
    let
      inherit (lib.modules) mkAfter;
      inherit (lib.strings) escapeShellArg;

      primaryUser = config.system.primaryUser;
      userHome = config.users.users.${primaryUser}.home;
      screenshotsDir = "${userHome}/Pictures/screenshots";
    in
    {
      security.pam.services.sudo_local = {
        touchIdAuth = true;
        reattach = true;
      };

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
          show-recents = false;
        };

        finder = {
          AppleShowAllExtensions = true;
          AppleShowAllFiles = true;
          FXEnableExtensionChangeWarning = false;
          FXPreferredViewStyle = "Nlsv";
          FXRemoveOldTrashItems = true;
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
          AppleSpacesSwitchOnActivate = false;
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

        CustomSystemPreferences = {
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
            FxDefaultSearchScope = "SCcf";
            WarnOnEmptyTrash = false;
          };

          "com.apple.screensaver" = {
            askForPassword = 1;
            askForPasswordDelay = 0;
          };
        };

        CustomUserPreferences."com.mitchellh.ghostty".NSUserKeyEquivalents = {
          "Hide Ghostty" = "@~^$h";
          "Hide Others" = "@~^$o";
        };

        controlcenter.BatteryShowPercentage = true;

        loginwindow = {
          DisableConsoleAccess = true;
          GuestEnabled = false;
        };

        menuExtraClock = {
          Show24Hour = true;
          ShowSeconds = true;
        };

        screencapture = {
          disable-shadow = true;
          location = screenshotsDir;
          type = "png";
        };
      };

      # screencapture silently falls back to the Desktop when its target does
      # not exist, so create it before defaults are applied.
      system.activationScripts.postActivation.text = mkAfter ''
        /usr/bin/install -d -o ${primaryUser} -g staff ${escapeShellArg screenshotsDir}
      '';
    };
}
