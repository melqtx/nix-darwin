{ ... }:

{
  perSystem =
    { pkgs, ... }:
    {
      packages.sync-pi-setup = pkgs.callPackage (
        {
          coreutils,
          jq,
          nodejs_24,
          rsync,
          writeShellApplication,
        }:
        writeShellApplication {
          name = "sync-pi-setup";
          runtimeInputs = [
            coreutils
            jq
            nodejs_24
            rsync
          ];
          text = /* bash */ ''
            sourceDir="$HOME/Documents/code/playground/my-pi-setup"
            agentDir="$HOME/.pi/agent"

            if [ ! -d "$sourceDir" ]; then
              echo "Pi setup not found at $sourceDir" >&2
              exit 1
            fi

            mkdir --parents "$agentDir" "$agentDir/skills"

            # Static setup sources are explicit user-owned syncs. Preserve each
            # extension's installed node_modules while removing stale sources.
            rsync --archive --delete --chmod=u+w \
              --filter='P node_modules/' \
              "$sourceDir/extensions/" "$agentDir/extensions/"
            rsync --archive --delete --chmod=u+w \
              "$sourceDir/themes/" "$agentDir/themes/"
            rsync --archive --delete --chmod=u+w \
              --filter='P node_modules/' \
              --filter='P .venv/' \
              "$sourceDir/skills/" "$agentDir/skills/"
            cp "$sourceDir/package.json" "$sourceDir/package-lock.json" "$agentDir/"
            chmod u+w "$agentDir/package.json" "$agentDir/package-lock.json"

            npm install --prefix "$agentDir"
            for ext in "$agentDir"/extensions/*/; do
              if [ -f "$ext/package.json" ]; then
                npm install --prefix "$ext"
              fi
            done

            settingsFile="$agentDir/settings.json"
            source=/dev/null
            if [[ -e "$settingsFile" || -L "$settingsFile" ]]; then
              source="$settingsFile"
            fi

            tmp=$(mktemp "$agentDir/.settings.json.sync.XXXXXX")
            trap 'rm --force "$tmp"' EXIT
            jq --slurp --slurpfile desired "$sourceDir/settings.example.json" '
              (if length == 0 then {} elif length == 1 and (.[0] | type) == "object"
               then .[0] else error("Expected one Pi settings object") end)
              | if ($desired | length) != 1 or ($desired[0] | type) != "object"
                then error("Expected one Pi setup settings object") else . end
              | .theme = $desired[0].theme
              | .themes = $desired[0].themes
              | .skills = $desired[0].skills
              | .extensions = $desired[0].extensions
              | .packages = $desired[0].packages
              | .["observational-memory"] = $desired[0]["observational-memory"]
            ' "$source" > "$tmp"
            if [[ -f "$settingsFile" ]]; then
              chmod --reference="$settingsFile" "$tmp"
            fi
            mv --force "$tmp" "$settingsFile"
            trap - EXIT

            echo "Pi setup synced successfully."
          '';
        }
      ) { };
    };
}
