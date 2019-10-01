;; swap ctrl and caps lock
(if (and (string-equal system-type "gnu/linux") (eq (display-graphic-p) t))    
    (call-process-shell-command "setxkbmap -option ctrl:nocaps&" nil 0))
;; Fancy battery
(if (eq (display-graphic-p) t)
    (progn
      (require-package 'fancy-battery)
      (add-hook 'after-init-hook #'fancy-battery-mode)))
;; Start dropbox daemon
(if (and (file-directory-p "~/.dropbox-dist") (not (string-equal "" (shell-command-to-string "pidof dropbox"))))
    (call-process-shell-command "~/.dropbox-dist/dropboxd&" nil 0))

(provide 'config-general)
