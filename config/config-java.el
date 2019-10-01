(defgroup dotemacs-java nil
  "Configuration options for Javascript."
  :group 'dotemacs
  :prefix 'dotemacs-java)

(defcustom dotemacs-java/indent-offset 4
  "The number of spaces to indent nested statements."
  :type 'integer
  :group 'dotemacs-java)

(defcustom dotemacs-java/use-lsp t
  "Enable LSP for JavaScript buffers."
  :type 'boolean
  :group 'dotemacs-java)



(setq java-indent-level dotemacs-java/indent-offset)

(when dotemacs-java/use-lsp
  (add-hook 'java-mode-hook #'/lsp/activate)  
  (add-hook 'lsp-after-open-hook #'lsp-ui-mode)
  (setq company-lsp-enable-snippet t
        company-lsp-cache-candidates t)
  (push 'company-lsp company-backends)
  (push 'java-mode company-global-modes)

  (require-package 'use-package)
  (use-package lsp-mode
               :hook (java-mode . lsp)
               :commands lsp)

  (require 'cc-mode)

  (use-package projectile :ensure t)
  (use-package yasnippet :ensure t)
  (use-package lsp-mode :ensure t)
  (use-package hydra :ensure t)
  (use-package company-lsp :ensure t)
  (use-package lsp-ui :ensure t)
  (use-package lsp-java :ensure t :after lsp
               :config (add-hook 'java-mode-hook 'lsp))

  (add-hook 'java-mode-hook (lambda ()
                              (add-hook 'java-mode-hook (lambda ()
                                                          (setq c-basic-offset 4
                                                                tab-width 4
                                                                indent-tabs-mode t)))))


  (use-package dap-mode
               :ensure t :after lsp-mode
               :config
               (dap-mode t)
               (dap-ui-mode t)))

(provide 'config-java)
