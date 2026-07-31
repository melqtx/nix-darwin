{ ... }:

{
  flake.homeModules.pi =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      inherit (lib.meta) getExe;

      agentDir = "${config.home.homeDirectory}/.pi/agent";

      # Prefer the editable local setup when it is visible to Nix. The
      # fallback keeps builds working in contexts that cannot see ~/Documents
      # (for example a remote nix-daemon or another machine).
      localPiSetup = /Users/melqtx/Documents/code/playground/my-pi-setup;

      piSetupSrc =
        if builtins.pathExists localPiSetup then
          builtins.path {
            path = localPiSetup;
            name = "my-pi-setup";
            filter =
              path: _:
              let
                baseName = builtins.baseNameOf path;
              in
              baseName != ".git" && baseName != "node_modules";
          }
        else
          pkgs.fetchFromGitHub {
            owner = "davis7dotsh";
            repo = "my-pi-setup";
            rev = "21f40f41fb98e088281a6fcd512388d82bddf911";
            hash = "sha256-3UfFeriLBXCnI4ensGUIPIrMgcGUFtRmrW9M2N+tCP4=";
          };

      emptySettings = pkgs.writeText "pi-empty-settings.json" "{}";
    in
    {
      # ~/.pi/agent already holds real auth.json/sessions/settings.json from
      # daily use, so this can't be a plain git clone (target must be empty)
      # or a home.file symlink (npm needs to write node_modules alongside).
      # Instead, vendor the static parts on every activation and merge the
      # theme into the existing settings.json rather than replacing it.
      home.activation.installPiSetup = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        export PATH="${pkgs.nodejs_24}/bin:$PATH"

        $DRY_RUN_CMD /bin/mkdir -p "${agentDir}"

        # Each extension is its own little npm package (effect, firecrawl,
        # etc. as *its* dependencies, not the root's), so node_modules lives
        # per-extension. --filter=P keeps --delete from nuking those between
        # activations; only the vendored sources get resynced every time.
        $DRY_RUN_CMD ${getExe pkgs.rsync} --archive --delete --chmod=u+w \
          --filter='P node_modules/' \
          "${piSetupSrc}/extensions/" "${agentDir}/extensions/"
        $DRY_RUN_CMD ${getExe pkgs.rsync} --archive --delete --chmod=u+w \
          "${piSetupSrc}/themes/" "${agentDir}/themes/"
        $DRY_RUN_CMD ${getExe pkgs.rsync} --archive --chmod=u+w \
          "${piSetupSrc}/skills/background-terminals" "${piSetupSrc}/skills/subagents" \
          "${agentDir}/skills/"
        $DRY_RUN_CMD /bin/cp "${piSetupSrc}/package.json" "${piSetupSrc}/package-lock.json" "${agentDir}/"
        $DRY_RUN_CMD /bin/chmod u+w "${agentDir}/package.json" "${agentDir}/package-lock.json"

        $DRY_RUN_CMD npm install --prefix "${agentDir}" \
          || echo "pi agent npm install failed; run manually" >&2

        for ext in "${agentDir}"/extensions/*/; do
          if [ -f "$ext/package.json" ]; then
            $DRY_RUN_CMD npm install --prefix "$ext" \
              || echo "npm install failed in $ext" >&2
          fi
        done

        settingsFile="${agentDir}/settings.json"
        if [ ! -e "$settingsFile" ]; then
          $DRY_RUN_CMD /bin/cp "${emptySettings}" "$settingsFile"
          $DRY_RUN_CMD /bin/chmod u+w "$settingsFile"
        fi

        # jq only reads here; the actual write goes through tee so it's the
        # one part of this line $DRY_RUN_CMD can gate. Preserve personal Pi
        # settings while keeping the setup's theme/resource paths in sync.
        merged="$(${getExe pkgs.jq} '
          .theme = "violet-night" |
          .themes = ["themes"] |
          .skills = ["skills"] |
          .extensions = [
            "extensions/ui-customization",
            "extensions/git-info",
            "extensions/model-info",
            "extensions/file-search",
            "extensions/copy-all"
          ] |
          .packages = ((.packages // []) | if index("npm:@pandi-coding-agent/plan") then . else . + ["npm:@pandi-coding-agent/plan"] end)
        ' "$settingsFile" 2>/dev/null)"
        if [ -n "$merged" ]; then
          printf '%s' "$merged" | $DRY_RUN_CMD /usr/bin/tee "$settingsFile" > /dev/null
        fi
      '';
    };
}
