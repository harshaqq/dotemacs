;; swap ctrl and caps lock
(if (and (string-equal system-type "gnu/linux") (eq (display-graphic-p) t))    
    (call-process-shell-command "setxkbmap -option ctrl:nocaps&" nil 0))
;; Fancy battery
(if (eq (display-graphic-p) t)
    (progn
      (require-package 'fancy-battery)
      (fancy-battery-mode)
      (menu-bar-mode -1)))

;; Start dropbox daemon
(if (file-directory-p "~/.dropbox-dist")
    (call-process-shell-command "~/.dropbox-dist/dropboxd&" nil 0))

(provide 'config-general)
