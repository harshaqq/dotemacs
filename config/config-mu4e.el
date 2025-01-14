(after 'mu4e

  (add-to-list 'load-path "/usr/share/emacs/site-lisp/mu4e/")
  (require 'mu4e)
  (require-package 'org-mu4e)
  (setq org-mu4e-link-query-in-headers-mode nil)

  ;; use mu4e for e-mail in emacs
  (setq mail-user-agent 'mu4e-user-agent)

  ;; default
  (setq mu4e-maildir (expand-file-name "~/.mail/gmail"))

  (setq mu4e-drafts-folder "/[Gmail].Drafts")
  (setq mu4e-sent-folder   "/[Gmail].Sent Mail")
  (setq mu4e-trash-folder  "/[Gmail].Trash")

  ;; don't save message to Sent Messages, Gmail/IMAP takes care of this
  (setq mu4e-sent-messages-behavior 'delete)

  ;; (See the documentation for `mu4e-sent-messages-behavior' if you have
  ;; additional non-Gmail addresses and want assign them different
  ;; behavior.)

  ;; setup some handy shortcuts
  ;; you can quickly switch to your Inbox -- press ``ji''
  ;; then, when you want archive some messages, move them to
  ;; the 'All Mail' folder by pressing ``ma''.

  (setq mu4e-maildir-shortcuts
        '( ("/Inbox"               . ?i)
           ("/[Gmail].Sent Mail"   . ?s)
           ("/[Gmail].Trash"       . ?t)
           ("/[Gmail].All Mail"    . ?a)))

  ;; allow for updating mail using 'U' in the main view:
  (setq mu4e-get-mail-command "true")

  ;; something about ourselves
  (setq
   user-mail-address (substring (shell-command-to-string "git config --global user.gpg") 0 -1)
   user-full-name  (substring (shell-command-to-string "git config --global user.name") 0 -1)
   mu4e-compose-signature
   (concat
    (substring (shell-command-to-string "git config --global user.name") 0 -1)
    ""))

  (require 'smtpmail)
  (setq message-send-mail-function 'smtpmail-send-it
        starttls-use-gnutls t
        smtpmail-starttls-credentials '(("smtp.gmail.com" 587 nil nil))
        smtpmail-auth-credentials
        '(("smtp.gmail.com" 587 (substring (shell-command-to-string "git config --global user.gpg") 0 -1) nil))
        smtpmail-default-smtp-server "smtp.gmail.com"
        smtpmail-smtp-server "smtp.gmail.com"
        smtpmail-smtp-service 587)

  ;; don't keep message buffers around
  (setq message-kill-buffer-on-exit t))

(provide 'config-mu4e)
