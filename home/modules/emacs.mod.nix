{ ... }:

{
  flake.homeModules.emacs =
    { config, lib, pkgs, ... }:
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
               doom-dashboard
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
               org
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

        (setq org-directory "~/org/")
      '';

      xdg.configFile."doom/packages.el".text = /* elisp */ ''
        ;;; packages.el -*- lexical-binding: t; -*-
      '';

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
        fi

        $DRY_RUN_CMD "${doomDir}/bin/doom" sync \
          || echo "doom sync failed; run 'doom sync' manually" >&2
      '';
    };
}
