{ config, ... }:

let
  inherit (config) profile;
in
{
  flake.homeModules.version-control =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      inherit (lib.lists) singleton;
      inherit (lib.meta) getExe;
      jj = getExe pkgs.jujutsu;
      shellAliases = {
        j = getExe pkgs.jjui;
        js = "${jj} status";
        jd = "${jj} diff";
        jl = "${jj} log";
        jn = "${jj} new";
        jc = "${jj} commit";
        jcp = "${jj} checkpoint";
        jb = "${jj} bookmark list";
        jf = "${jj} git fetch";
        jop = "${jj} ops";
        jsh = "${jj} show";
        ju = "${jj} undo";
      };

      user = {
        inherit (profile) name email;
      };

      gitSettings = {
        inherit user;

        init.defaultBranch = "main";
        core.editor = config.home.sessionVariables.EDITOR;

        fetch = {
          prune = true;
          fsckObjects = true;
        };

        pull.rebase = false;
        receive.fsckObjects = true;
        transfer.fsckObjects = true;
        credential.helper = "osxkeychain";
      };

      jjSettings = {
        inherit user;

        aliases = {
          ".." = [
            "edit"
            "@-"
          ];
          ",," = [
            "edit"
            "@+"
          ];
          a = [
            "file"
            "track"
          ];
          c = singleton "commit";
          d = singleton "diff";
          e = singleton "edit";
          f = [
            "git"
            "fetch"
          ];
          l = singleton "log";
          la = [
            "log"
            "--revisions"
            "::"
          ];
          n = singleton "new";
          p = [
            "git"
            "push"
          ];
          resolve-ast = [
            "resolve"
            "--tool"
            "mergiraf"
          ];
          s = singleton "status";
          sh = singleton "show";
          sq = singleton "squash";
          sqi = [
            "squash"
            "--interactive"
          ];
          u = singleton "undo";
          checkpoint = singleton "commit";
          review = [
            "diff"
            "--stat"
          ];
          stack = [
            "log"
            "--revisions"
            "trunk()..@ | trunk()"
          ];
          ops = [
            "op"
            "log"
            "--limit"
            "12"
          ];
          rebase-trunk = [
            "rebase"
            "--destination"
            "trunk()"
          ];
          push-preview = [
            "git"
            "push"
            "--dry-run"
          ];
        };

        git.colocate = true;

        merge-tools.mergiraf.program = getExe pkgs.mergiraf;

        revsets.log = /* jj-revset */ ''
          present(@) | present(trunk()) | ancestors(remote_bookmarks().. | @.., 8)
        '';

        ui = {
          default-command = "status";
          editor = config.home.sessionVariables.EDITOR;
          conflict-marker-style = "snapshot";
          diff-editor = ":builtin";
          graph.style = "curved";
        };

        fsmonitor = {
          backend = "watchman";
          watchman.register-snapshot-trigger = true;
        };

        templates = {
          draft_commit_description = /* jj-template */ ''
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

          git_push_bookmark = ''"mel/change-" ++ change_id.short()'';
        };

        remotes."*" = {
          auto-track-bookmarks = "mel/*";
          push-new-bookmarks = true;
        };
      };

    in
    {
      home.packages = [
        pkgs.jjui
        pkgs.lazyjj
        pkgs.lazygit
        pkgs.gh
        pkgs.mergiraf
        pkgs.watchman
      ];

      xdg.configFile."git/config".enable = false;
      home.file.".gitconfig" = {
        force = true;
        source = config.xdg.configFile."git/config".source;
      };

      programs.git = {
        enable = true;
        settings = gitSettings;
      };
      programs.jujutsu = {
        enable = true;
        ediff = false;
        settings = jjSettings;
      };
      programs.fish.shellAliases = shellAliases;
      programs.nushell.shellAliases = shellAliases;
      programs.gpg.enable = true;
      programs.delta = {
        enable = true;
        enableGitIntegration = true;
        enableJujutsuIntegration = true;
        options = {
          dark = true;
          navigate = true;
          line-numbers = true;
        };
      };

      # Signing remains opt-in until a concrete private key is declared. Let
      # GnuPG start its agent on demand: the supervised launchd service crash-
      # loops on current macOS/GnuPG before any signing request is made.
      home.file.".gnupg/gpg-agent.conf".text = /* conf */ ''
        default-cache-ttl 3600
        max-cache-ttl 7200
        pinentry-program ${getExe pkgs.pinentry_mac}
      '';

      services.gpg-agent.enable = false;

    };
}
