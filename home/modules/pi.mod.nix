{ ... }:

{
  flake.homeModules.pi =
    { pkgs, ... }:
    let
      piSetupSrc = "/Users/melqtx/Documents/code/playground/my-pi-setup";

      syncPiSetup = pkgs.writeShellApplication {
        name = "sync-pi-setup";
        runtimeInputs = [
          pkgs.coreutils
          pkgs.jq
          pkgs.nodejs_24
          pkgs.rsync
        ];
        text = ''
          sourceDir=${piSetupSrc}
          agentDir="$HOME/.pi/agent"

          if [ ! -d "$sourceDir" ]; then
            echo "Pi setup not found at $sourceDir" >&2
            exit 1
          fi

          mkdir -p "$agentDir" "$agentDir/skills"

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
          if [ ! -e "$settingsFile" ]; then
            printf '{}\n' > "$settingsFile"
            chmod u+w "$settingsFile"
          fi

          tmp=$(mktemp "$agentDir/.settings.json.sync.XXXXXX")
          trap 'rm -f "$tmp"' EXIT
          jq --slurpfile desired "$sourceDir/settings.example.json" '
            .theme = $desired[0].theme |
            .themes = $desired[0].themes |
            .skills = $desired[0].skills |
            .extensions = $desired[0].extensions |
            .packages = $desired[0].packages |
            .["observational-memory"] = $desired[0]["observational-memory"]
          ' "$settingsFile" > "$tmp"
          chmod --reference="$settingsFile" "$tmp"
          mv -f "$tmp" "$settingsFile"
          trap - EXIT

          echo "Pi setup synced successfully."
        '';
      };
    in
    {
      # Syncing external sources and running npm are intentionally explicit;
      # a system rebuild must remain local and deterministic.
      home.packages = [ syncPiSetup ];
    };
}
