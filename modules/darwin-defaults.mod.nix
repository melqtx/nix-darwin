{ ... }:

{
  flake.darwinModules.darwin-defaults = {
    # Right cmd becomes F18, which hammerspoon treats as the Hyper layer
    # (hold + hjkl = window focus). Applies to all keyboards; the internal
    # one has no right cmd, so it only affects the HHKB in practice.
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
        FXPreferredViewStyle = "Nlsv";
      };

      NSGlobalDomain = {
        ApplePressAndHoldEnabled = false;
        InitialKeyRepeat = 15;
        KeyRepeat = 2;
      };

      CustomUserPreferences."com.mitchellh.ghostty".NSUserKeyEquivalents = {
        "Hide Ghostty" = "@~^$h";
        "Hide Others" = "@~^$o";
      };
    };
  };
}
