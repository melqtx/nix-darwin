{ ... }:

{
  flake.homeModules.claude-code =
    { lib, pkgs, ... }:
    let
      inherit (lib.lists) singleton;

      # A space before the trailing * enforces a word boundary: "ls *"
      # matches `ls -la` and bare `ls`, but not `lsof`.
      allowedCommands = [
        "rg *"
        "ls *"
        "eza *"
        "fd *"
        "tokei *"

        "jj bookmark list*"
        "jj config get*"
        "jj config list*"
        "jj diff*"
        "jj evolog*"
        "jj file annotate*"
        "jj file list*"
        "jj file show*"
        "jj help*"
        "jj interdiff*"
        "jj log*"
        "jj op diff*"
        "jj op log*"
        "jj op show*"
        "jj resolve --list"
        "jj root*"
        "jj show*"
        "jj st*"
        "jj status*"
        "jj version*"
        "jj workspace list*"
        "jj workspace root*"

        "git branch*"
        "git diff*"
        "git log*"
        "git remote -v"
        "git show*"
        "git status*"

        "gh auth status*"
        "gh issue list*"
        "gh issue view*"
        "gh pr checks*"
        "gh pr diff*"
        "gh pr list*"
        "gh pr status*"
        "gh pr view*"
        "gh release list*"
        "gh release view*"
        "gh repo view*"
        "gh run list*"
        "gh run view*"

        "nix eval*"
        "nix flake metadata*"
        "nix flake show*"
        "nix-instantiate --parse*"
      ];

      settings = (pkgs.formats.json { }).generate "claude-settings.json" {
        "$schema" = "https://json.schemastore.org/claude-code-settings.json";

        # Preserve the model selected in the pre-existing settings file.
        model = "claude-fable-5[1m]";

        permissions = {
          allow = map (command: "Bash(${command})") allowedCommands ++ [
            "Glob"
            "Grep"
            "WebFetch"
            "WebSearch"
          ];

          # A recursive find over the Nix store can effectively hang a session.
          deny = singleton "Bash(find /nix/store*)";
        };

        env = {
          CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY = "1";
          DISABLE_ERROR_REPORTING = "1";
          DISABLE_TELEMETRY = "1";
        };
      };
    in
    {
      home.file.".claude/settings.json" = {
        force = true;
        source = settings;
      };
    };
}
