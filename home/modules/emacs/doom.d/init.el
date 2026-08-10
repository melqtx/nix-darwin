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
