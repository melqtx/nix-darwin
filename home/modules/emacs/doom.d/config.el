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
           :if-new (file+head "main/${slug}.org" "#+title: ${title}\n")
           :immediate-finish t
           :unnarrowed t)
          ("r" "reference" plain "%?"
           :if-new (file+head "reference/${title}.org" "#+title: ${title}\n")
           :immediate-finish t
           :unnarrowed t)
          ("a" "article" plain "%?"
           :if-new (file+head "articles/${title}.org" "#+title: ${title}\n#+filetags: :article:\n")
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
