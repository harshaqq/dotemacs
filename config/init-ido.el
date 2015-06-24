(when (eq dotemacs-switch-engine 'ido)
  (require 'ido)
  (setq ido-enable-prefix nil)
  (setq ido-use-virtual-buffers t)
  (setq ido-enable-flex-matching t)
  (setq ido-create-new-buffer 'always)
  (setq ido-use-filename-at-point 'guess)
  (setq ido-save-directory-list-file (concat dotemacs-cache-directory "ido.last"))

  (ido-mode t)
  (ido-everywhere t)

  (require-package 'ido-ubiquitous)
  (ido-ubiquitous-mode t)

  (require-package 'flx-ido)
  (flx-ido-mode t)

  (require-package 'ido-vertical-mode)
  (ido-vertical-mode)
  )

(provide 'init-ido)
