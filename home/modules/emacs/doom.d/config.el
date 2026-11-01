;;; config.el -*- lexical-binding: t; -*-

(setq user-full-name @userFullName@
      user-mail-address @userEmail@)

(setq doom-font (font-spec :family @editorFont@ :size @fontSize@)
      doom-theme 'doom-one
      display-line-numbers-type 'relative
      shell-file-name (executable-find "bash"))

(setq-default vterm-shell (getenv "SHELL")
              explicit-shell-file-name (getenv "SHELL"))

(after! doom-themes
  (custom-set-faces!
    '(default :background @background@ :foreground @foreground@)
    '(solaire-default-face :background @background@ :foreground @foreground@)
    '(fringe :background @background@)
    '(cursor :background @accent@)
    '(region :background @selection@ :foreground @foreground@)
    '(hl-line :background @highlight@)
    '(line-number :foreground @muted@ :background @background@)
    '(line-number-current-line :foreground @accent@ :background @background@)
    '(vertical-border :foreground @border@)
    '(mode-line :background @modeline@ :foreground @foreground@)
    '(mode-line-inactive :background @background@ :foreground @muted@)))

(defconst melqtx/org-agenda-file-names '("todo.org" "inbox.org"))

(setq org-directory (expand-file-name "~/Documents/org/")
      org-archive-location (concat org-directory "archive/%s_archive::")
      org-roam-directory (file-truename org-directory))

(after! org
  (setq org-agenda-files
        (mapcar (lambda (file) (expand-file-name file org-directory))
                melqtx/org-agenda-file-names)
        org-agenda-span 7
        org-agenda-start-on-weekday nil
        org-agenda-window-setup 'current-window
        org-agenda-restore-windows-after-quit t
        org-agenda-skip-deadline-if-done t
        org-agenda-skip-scheduled-if-done t
        org-agenda-skip-timestamp-if-done t
        org-deadline-warning-days 14
        org-log-done 'time
        org-log-into-drawer t
        org-hide-emphasis-markers t
        org-startup-folded 'content
        org-startup-indented t
        org-image-actual-width '(700)
        org-ellipsis " ▾"
        org-todo-keywords '((sequence "TODO(t)" "|" "DONE(d!)"))
        org-refile-targets '(("todo.org" :maxlevel . 3)
                             ("archive/archive.org" :maxlevel . 2))
        org-outline-path-complete-in-steps nil
        org-refile-use-outline-path 'file
        org-capture-templates
        '(("i" "Inbox" entry (file "inbox.org")
           "* %U %i" :immediate-finish t :empty-lines 1))
        org-agenda-custom-commands
        '(("d" "Dashboard"
           ((tags "inbox"
                  ((org-agenda-files
                    (list (expand-file-name "inbox.org" org-directory)))
                   (org-agenda-overriding-header " INBOX")
                   (org-agenda-skip-function
                    '(org-agenda-skip-entry-if 'regexp "^\\*+ Captures"))))
            (agenda "" ((org-agenda-overriding-header " NEXT 7 DAYS")
                         (org-agenda-span 7)))
            (alltodo "" ((org-agenda-files
                           (list (expand-file-name "todo.org" org-directory)))
                          (org-agenda-overriding-header " TASKS")))))))
  (global-org-modern-mode 1))

(after! org-roam
  (setq org-roam-capture-templates
        '(("n" "note" plain "%?"
           :if-new (file+head "roam/${slug}.org" "#+title: ${title}\n")
           :unnarrowed t)))
  (org-roam-db-autosync-mode 1))

(defun melqtx/org-inbox-capture (text)
  "Capture TEXT into the unprocessed Org inbox."
  (interactive (list (string-trim (read-string "Inbox: "))))
  (when (string-empty-p text)
    (user-error "Inbox entry cannot be empty"))
  (org-capture-string text "i")
  (message "Captured: %s" text))

(map! :leader
      (:prefix ("n" . "notes")
       :desc "Capture to inbox" "n" #'melqtx/org-inbox-capture
       :desc "Org dashboard" "d" (cmd! (org-agenda nil "d"))
       :desc "Find or create note" "f" #'org-roam-node-find))
(after! persp-mode
  (remove-hook 'server-done-hook #'+workspaces-delete-associated-workspace-h))
