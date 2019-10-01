(require-package 'emms)


(add-hook 'emms-player-started-hook 'emms-show)
(setq emms-show-format "Playing: %s")
(emms-standard)
(emms-default-players)

(provide 'config-emms)
