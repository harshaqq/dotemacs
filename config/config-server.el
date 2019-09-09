(unless (server-running-p)
  (print "* Starting emacs server *")
  (server-start))

(provide 'config-server)
