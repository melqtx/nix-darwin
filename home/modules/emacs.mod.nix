{ ... }:

{
  flake.homeModules.emacs =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      inherit (lib.meta) getExe;

      git = getExe pkgs.git;
      doomDir = "${config.home.homeDirectory}/.config/emacs";
    in
    {
      xdg.configFile."doom/init.el".text = /* elisp */ ''
        ;;; init.el -*- lexical-binding: t; -*-

        (doom! :input

               :completion
               company
               vertico

               :ui
               doom
               dashboard
               hl-todo
               modeline
               ophints
               (popup +defaults)
               treemacs
               vc-gutter
               vi-tilde-fringe
               window-select
               workspaces

               :editor
               (evil +everywhere)
               file-templates
               fold
               snippets

               :emacs
               dired
               electric
               ibuffer
               undo
               vc

               :term
               eshell
               vterm

               :checkers
               syntax

               :tools
               direnv
               (eval +overlay)
               lookup
               lsp
               magit
               tree-sitter

               :os
               macos
               tty

               :lang
               data
               emacs-lisp
               json
               javascript
               markdown
               nix
               (org +pretty +roam2)
               sh
               web

               :config
               (default +bindings +smartparens))
      '';

      xdg.configFile."doom/config.el".text = /* elisp */ ''
        ;;; config.el -*- lexical-binding: t; -*-

        (setq user-full-name "melqtx"
              user-mail-address "melqtx@proton.me")

        (setq doom-font (font-spec :family "JetBrainsMono Nerd Font" :size 15)
              doom-theme 'doom-one
              display-line-numbers-type 'relative)

        (setq org-directory "~/Documents/org/")

        (after! org
          (setq org-agenda-files (list org-directory)
                org-log-done 'time
                org-hide-emphasis-markers t
                org-startup-folded 'content
                org-todo-keywords
                '((sequence "TODO(t)" "NEXT(n)" "WAIT(w)" "|" "DONE(d)" "KILL(k)"))))

        (setq org-roam-directory (file-truename "~/Documents/org/roam/"))

        ;; org-roam note structure and bindings after jvscholz/dotfiles
        (after! org-roam
          (setq org-roam-capture-templates
                '(("m" "main" plain "%?"
                   :if-new (file+head "main/''${slug}.org" "#+title: ''${title}\n")
                   :immediate-finish t
                   :unnarrowed t)
                  ("r" "reference" plain "%?"
                   :if-new (file+head "reference/''${title}.org" "#+title: ''${title}\n")
                   :immediate-finish t
                   :unnarrowed t)
                  ("a" "article" plain "%?"
                   :if-new (file+head "articles/''${title}.org" "#+title: ''${title}\n#+filetags: :article:\n")
                   :immediate-finish t
                   :unnarrowed t))))

        (map! "C-c n l" #'org-roam-buffer-toggle
              "C-c n f" #'org-roam-node-find
              "C-c n g" #'org-roam-graph
              "C-c n i" #'org-roam-node-insert
              "C-c n c" #'org-roam-capture
              "C-c n j" #'org-roam-dailies-capture-today)

        (use-package! org-roam-ui
          :after org-roam
          :config
          (setq org-roam-ui-sync-theme t
                org-roam-ui-follow t
                org-roam-ui-update-on-save t))
      '';

      xdg.configFile."doom/packages.el".text = /* elisp */ ''
        ;;; packages.el -*- lexical-binding: t; -*-

        (package! org-roam-ui)
      '';

      home.file."Documents/org/roam/.keep".text = "";
      home.file."Documents/org/roam/main/.keep".text = "";
      home.file."Documents/org/roam/reference/.keep".text = "";
      home.file."Documents/org/roam/articles/.keep".text = "";

      programs.emacs = {
        enable = true;
        package = pkgs.emacs30;
      };

      services.emacs.enable = true;

      # Doom itself is not packaged declaratively (it wants straight.el to
      # fetch packages over git), so bootstrap the framework once and let it
      # resync on every activation. Requires network access on first run.
      # The activation PATH lacks emacs and git, which doom needs internally.
      home.activation.installDoomEmacs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        export PATH="${config.programs.emacs.finalPackage}/bin:${pkgs.git}/bin:$PATH"

        if [ ! -d "${doomDir}" ]; then
          $DRY_RUN_CMD ${git} clone --depth 1 https://github.com/doomemacs/doomemacs "${doomDir}"

          # 'doom sync' alone is not enough on a fresh clone: current Doom
          # master fetches its module sources during 'doom install' only,
          # otherwise every module resolves to &nopath and no packages install.
          $DRY_RUN_CMD "${doomDir}/bin/doom" install --force --no-config --no-env \
            || echo "doom install failed; run 'doom install' manually" >&2
        fi

        $DRY_RUN_CMD "${doomDir}/bin/doom" sync \
          || echo "doom sync failed; run 'doom sync' manually" >&2
      '';
    };
}
