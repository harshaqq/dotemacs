(after 'mu4e-mode
  (setq mu4e-contexts
        `( ,(make-mu4e-context
             :name "Gmail"
             :match-func (lambda (msg) (when msg
                                         (string-prefix-p "/Gmail" (mu4e-message-field msg :maildir))))
             :vars '(
                     (mu4e-trash-folder . "/Gmail/[Gmail].Trash")
                     (mu4e-refile-folder . "/Gmail/[Gmail].Archive")
                     ))))

  (require-package 'org-mu4e)
  (setq org-mu4e-link-query-in-headers-mode nil))

(provide 'config-mu4e)
