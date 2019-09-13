
(setq
 chess-default-display 'chess-plain
 chess-ics-server-list '(("freechess.org" 5000 "mlang"))
 chess-plain-draw-border t
 chess-plain-white-square-char 45
 chess-plain-spacing 0)
(setq chess-plain-piece-chars
      (quote
       ((75 . 9812)
        (81 . 9813)
        (82 . 9814)
        (66 . 9815)
        (78 . 9816)
        (80 . 9817)
        (107 . 9818)
        (113 . 9819)
        (114 . 9820)
        (98 . 9821)
        (110 . 9822)
        (112 . 9823))))

(provide 'config-chess)
