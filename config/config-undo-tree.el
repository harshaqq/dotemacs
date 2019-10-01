
(setq undo-tree-visualizer-timestamps t)
(setq undo-tree-visualizer-relative-timestamps t)
(setq undo-tree-visualizer-lazy-drawing t)
(setq undo-tree-visualizer-diff t)
(setq undo-tree-enable-undo-in-region t)
(setq undo-tree-auto-save-history t)
(defun undo-tree-visualizer-update-linum (&rest args)
  (linum-update undo-tree-visualizer-parent-buffer))
(advice-add 'undo-tree-visualize-undo :after #'undo-tree-visualizer-update-linum)
(advice-add 'undo-tree-visualize-redo :after #'undo-tree-visualizer-update-linum)
(advice-add 'undo-tree-visualize-undo-to-x :after #'undo-tree-visualizer-update-linum)
(advice-add 'undo-tree-visualize-redo-to-x :after #'undo-tree-visualizer-update-linum)
(advice-add 'undo-tree-visualizer-mouse-set :after #'undo-tree-visualizer-update-linum)
(advice-add 'undo-tree-visualizer-set :after #'undo-tree-visualizer-update-linum)

(provide 'config-undo-tree)