{ ... }:

{
  flake.darwinModules.darwin-defaults = {
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
        NSWindowResizeTime = 0.001;
      };

      CustomUserPreferences."com.mitchellh.ghostty".NSUserKeyEquivalents = {
        "Hide Ghostty" = "@~^$h";
        "Hide Others" = "@~^$o";
      };
    };
  };
}
