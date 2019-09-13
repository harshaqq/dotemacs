
(when (executable-find "sdcv")            ; check dictd is available
  (progn
    (require-package 'sdcv)
    (setq sdcv-say-word-p t)               ;say word after translation
    (setq sdcv-dictionary-data-dir "~/.stardict") ;setup directory of stardict dictionary)
    (setenv "LC_TIME" "en_IN.UTF-8")
    (setenv "LC_COLLATE" "en_IN.UTF-8")
    (setenv "LC_MONETARY" "en_IN.UTF-8")
    (setenv "LC_MESSAGES" "en_IN.UTF-8")
    ))

(provide 'config-dictionary)
