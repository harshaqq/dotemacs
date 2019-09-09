(defgroup dotemacs-js nil
  "Configuration options for Javascript."
  :group 'dotemacs
  :prefix 'dotemacs-ruby)

(defcustom dotemacs-ruby/indent-offset 2
  "The number of spaces to indent nested statements."
  :type 'integer
  :group 'dotemacs-ruby)

(defcustom dotemacs-ruby/use-lsp nil
  "Enable LSP for Ruby buffers."
  :type 'boolean
  :group 'dotemacs-ruby)

(defcustom dotemacs-ruby/use-electric t
  "Enable electric mode for ruby"
  :type 'boolean
  :group 'dotemacs-ruby)

(defcustom dotemacs-ruby/use-robe t
  "Enable robe for ruby"
  :type 'boolean
  :group 'dotemacs-ruby)

(after 'ruby-mode
  (setq ruby-indent-level dotemacs-ruby/indent-offset)  
  (require-package 'ruby-refactor)
  (require-package 'robe)
  (require-package 'ruby-electric)
  (require 'ruby-refactor)
  (when dotemacs-ruby/use-lsp
    (add-hook 'ruby-mode-hook #'/lsp/activate))

  (when dotemacs-ruby/use-electric
    (add-hook 'ruby-mode-hook 'ruby-electric-mode))

  (when dotemacs-ruby/use-robe
    (add-hook 'ruby-mode-hook 'robe-mode))
  
  (add-hook 'ruby-mode-hook #'ruby-refactor-mode)
  )

(provide 'config-ruby)
