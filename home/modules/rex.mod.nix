{ config, self, ... }:

let
  inherit (config) theme;
in
{
  # The invite-only macOS beta is installed and updated by Rex itself.
  # Resolve its current bundled CLI at runtime, including outside Rex shells.
  perSystem = { pkgs, ... }: {
    packages.rex-cli = pkgs.writeShellScriptBin "rex" /* bash */ ''
      for rex_bin in \
        "''${REX_BIN_DIR:+$REX_BIN_DIR/rex}" \
        "$HOME/Library/Application Support/com.superlogical.rex/RexServer/Versions/Current/Rex Server.app/Contents/MacOS/rex" \
        "/Applications/Rex Beta.app/Contents/Helpers/Rex Server.rex/Contents/MacOS/rex" \
        "/Applications/Rex.app/Contents/Helpers/Rex Server.rex/Contents/MacOS/rex"; do
        if [ -n "$rex_bin" ] && [ -x "$rex_bin" ]; then
          exec "$rex_bin" "$@"
        fi
      done
      echo "Rex is not installed. Install and open the macOS app first." >&2
      exit 127
    '';
  };

  flake.darwinModules.rex = { config, ... }: {
    imports = [ self.darwinModules.home-manager ];
    home-manager.users.${config.system.primaryUser}.imports = [ self.homeModules.rex ];

    # Nix replaces PATH when starting login shells; keep the matching Rex CLI.
    environment.interactiveShellInit = ''
      if [ -n "$REX_BIN_DIR" ]; then
        export PATH="$REX_BIN_DIR:$PATH"
      fi
    '';

    # Appearance themes remain owned by the app. These keys were verified
    # against the installed beta's Settings, rather than Ghostty config keys.
    system.defaults.CustomUserPreferences."com.superlogical.rex" = {
      "Workspace.terminalFontName" = theme.terminalFont;
      "Workspace.terminalFontPointSize" = theme.fontSize;
      "Workspace.terminalStartupCommand" =
        "/etc/profiles/per-user/${config.system.primaryUser}/bin/fish --login";
      "Workspace.terminalOptionKeyBehavior" = "actsAsAlt";
      "Workspace.terminalCopyOnSelect" = true;
      "Workspace.terminalCursorBlinkIntervalMilliseconds" = 0;
      "Workspace.terminalCursorBlinkUsesCustomInterval" = false;
      "Workspace.terminalUsesDisplayP3" = true;
      NSUserKeyEquivalents = {
        "Hide Rex Beta" = "@~^$h";
        "Hide Rex" = "@~^$h";
        "Hide Others" = "@~^$o";
      };
    };
  };

  flake.homeModules.rex =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      rex = self.packages.${pkgs.stdenv.hostPlatform.system}.rex-cli;
    in
    {
      home.packages = [ rex ];
      xdg.configFile."rex/init.lua".source = ./rex/init.lua;
      programs.fish.interactiveShellInit = lib.mkAfter /* fish */ ''
        if set -q REX_BIN_DIR; and test -d "$REX_BIN_DIR"
          fish_add_path --path --prepend --move "$REX_BIN_DIR"
        end
      '';
      programs.nushell.extraConfig = lib.mkAfter ''
        if ($env.REX_BIN_DIR? | default "" | is-not-empty) {
          $env.PATH = ($env.PATH | prepend $env.REX_BIN_DIR | uniq)
        }
      '';
      home.activation.reloadRexConfig = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
        # Do not start a server or interrupt running shells during activation.
        if [ -S "${config.home.homeDirectory}/Library/Application Support/rex/server.sock" ]; then
          $DRY_RUN_CMD ${lib.meta.getExe rex} --autostart=false config reload
        fi
      '';
    };
}
