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
      };
    };
  };
}
