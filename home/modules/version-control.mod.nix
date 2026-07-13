{ ... }:

{
  flake.homeModules.version-control =
    { lib, pkgs, ... }:
    let
      gitConfig = pkgs.writeText "gitconfig" (
        lib.generators.toGitINI {
          user = {
            name = "melqtx";
            email = "melqtx@proton.me";
          };

          init.defaultBranch = "main";
          core.editor = "nvim";

          fetch = {
            prune = true;
            fsckObjects = true;
          };

          pull.rebase = false;
          receive.fsckObjects = true;
          transfer.fsckObjects = true;
          credential.helper = "osxkeychain";
        }
      );

      jjConfig = (pkgs.formats.toml { }).generate "jj-config.toml" {
        user = {
          name = "melqtx";
          email = "melqtx@proton.me";
        };

        aliases = {
          a = [
            "file"
            "track"
          ];
          c = [ "commit" ];
          d = [ "diff" ];
          e = [ "edit" ];
          l = [ "log" ];
          n = [ "new" ];
          resolve-ast = [
            "resolve"
            "--tool"
            "${pkgs.mergiraf}/bin/mergiraf"
          ];
          s = [ "status" ];
          sh = [ "show" ];
          u = [ "undo" ];
        };

        revsets.log = ''
          present(@) | present(trunk()) | ancestors(remote_bookmarks().. | @.., 8)
        '';

        ui = {
          default-command = "status";
          conflict-marker-style = "snapshot";
          diff-formatter = [
            "${pkgs.difftastic}/bin/difft"
            "--color"
            "always"
            "$left"
            "$right"
          ];
          diff-editor = ":builtin";
          graph.style = "curved";
          pager = "less -FRX";
        };

        fsmonitor = {
          backend = "watchman";
          watchman.register-snapshot-trigger = true;
        };

        templates = {
          draft_commit_description = ''
            concat(
              coalesce(description, "\n"),
              surround(
                "\nJJ: This commit contains the following changes:\n", "",
                indent("JJ:     ", diff.stat(72)),
              ),
              "\nJJ: ignore-rest\n",
              diff.git(),
            )
          '';

          git_push_bookmark = ''"melqtx/change-" ++ change_id.short()'';
        };

        remotes."*" = {
          auto-track-bookmarks = "melqtx/*";
          push-new-bookmarks = true;
        };
      };

      watchmanConfig = (pkgs.formats.json { }).generate "watchman.json" {
        ignore_dirs = [
          ".direnv"
          "node_modules"
          "target"
        ];
      };
    in
    {
      home.packages = [
        pkgs.jujutsu
        pkgs.jjui
        pkgs.lazyjj
        pkgs.lazygit
        pkgs.delta
        pkgs.gh
        pkgs.mergiraf
        pkgs.watchman
      ];

      # Git ignores the XDG config when ~/.gitconfig exists, so migrate and
      # manage the pre-existing global file directly.
      home.file.".gitconfig" = {
        force = true;
        source = gitConfig;
      };

      programs.gpg.enable = true;

      # Signing remains opt-in until a concrete private key is declared.
      services.gpg-agent = {
        enable = true;
        defaultCacheTtl = 3600;
        enableFishIntegration = true;
        maxCacheTtl = 7200;
        pinentry.package = pkgs.pinentry_mac;
      };

      xdg.configFile."jj/config.toml".source = jjConfig;
      xdg.configFile."watchman/watchman.json".source = watchmanConfig;
    };
}
