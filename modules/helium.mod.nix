{ ... }:

{
  flake.darwinModules.helium =
    { lib, pkgs, ... }:
    let
      inherit (lib.meta) getExe;
      inherit (lib.modules) mkAfter;
    in
    {
      # Helium itself comes from the homebrew cask; extensions are managed by
      # hand. Managed policies were tried and dropped: any Chromium policy
      # permanently brands the browser "managed by your organization".
      system.activationScripts.postActivation.text = mkAfter ''
        # helium: assert default browser as the console user (macOS shows a
        # one-click confirmation dialog whenever the default actually changes)
        consoleUser=$(/usr/bin/stat -f %Su /dev/console)
        /usr/bin/sudo --set-home --user "$consoleUser" "${getExe pkgs.defaultbrowser}" helium || true
      '';
    };
}
