(after 'org
  (defgroup dotemacs-org nil
    "Configuration options for org-mode."
    :group 'dotemacs
    :prefix 'dotemacs-org)

  (defcustom dotemacs-org/journal-file (concat org-directory "/journal.org")
    "The path to the file where you want to make journal entries."
    :type 'file
    :group 'dotemacs-org)

  (setq org-directory "~/Dropbox/SecondBrain")

  (defun bh/is-project-p ()
    "Any task with a todo keyword subtask"
    (save-restriction
      (widen)
      (let ((has-subtask)
  	    (subtree-end (save-excursion (org-end-of-subtree t)))
  	    (is-a-task (member (nth 2 (org-heading-components)) org-todo-keywords-1)))
  	(save-excursion
  	  (forward-line 1)
  	  (while (and (not has-subtask)
  		      (< (point) subtree-end)
  		      (re-search-forward "^\*+ " subtree-end t))
  	    (when (member (org-get-todo-state) org-todo-keywords-1)
  	      (setq has-subtask t))))
  	(and is-a-task has-subtask))))

  (defun bh/is-project-subtree-p ()
    "Any task with a todo keyword that is in a project subtree.
  Callers of this function already widen the buffer view."
    (let ((task (save-excursion (org-back-to-heading 'invisible-ok)
  				(point))))
      (save-excursion
  	(bh/find-project-task)
  	(if (equal (point) task)
  	    nil
  	  t))))

  (defun bh/is-task-p ()
    "Any task with a todo keyword and no subtask"
    (save-restriction
      (widen)
      (let ((has-subtask)
  	    (subtree-end (save-excursion (org-end-of-subtree t)))
  	    (is-a-task (member (nth 2 (org-heading-components)) org-todo-keywords-1)))
  	(save-excursion
  	  (forward-line 1)
  	  (while (and (not has-subtask)
  		      (< (point) subtree-end)
  		      (re-search-forward "^\*+ " subtree-end t))
  	    (when (member (org-get-todo-state) org-todo-keywords-1)
  	      (setq has-subtask t))))
  	(and is-a-task (not has-subtask)))))

  (defun bh/is-subproject-p ()
    "Any task which is a subtask of another project"
    (let ((is-subproject)
  	  (is-a-task (member (nth 2 (org-heading-components)) org-todo-keywords-1)))
      (save-excursion
  	(while (and (not is-subproject) (org-up-heading-safe))
  	  (when (member (nth 2 (org-heading-components)) org-todo-keywords-1)
  	    (setq is-subproject t))))
      (and is-a-task is-subproject)))

  (defun bh/list-sublevels-for-projects-indented ()
    "Set org-tags-match-list-sublevels so when restricted to a subtree we list all subtasks.
    This is normally used by skipping functions where this variable is already local to the agenda."
    (if (marker-buffer org-agenda-restrict-begin)
  	(setq org-tags-match-list-sublevels 'indented)
      (setq org-tags-match-list-sublevels nil))
    nil)

  (defun bh/list-sublevels-for-projects ()
    "Set org-tags-match-list-sublevels so when restricted to a subtree we list all subtasks.
    This is normally used by skipping functions where this variable is already local to the agenda."
    (if (marker-buffer org-agenda-restrict-begin)
  	(setq org-tags-match-list-sublevels t)
      (setq org-tags-match-list-sublevels nil))
    nil)

  (defvar bh/hide-scheduled-and-waiting-next-tasks t)

  (defun bh/toggle-next-task-display ()
    (interactive)
    (setq bh/hide-scheduled-and-waiting-next-tasks (not bh/hide-scheduled-and-waiting-next-tasks))
    (when  (equal major-mode 'org-agenda-mode)
      (org-agenda-redo))
    (message "%s WAITING and SCHEDULED NEXT Tasks" (if bh/hide-scheduled-and-waiting-next-tasks "Hide" "Show")))

  (defun bh/skip-stuck-projects ()
    "Skip trees that are not stuck projects"
    (save-restriction
      (widen)
      (let ((next-headline (save-excursion (or (outline-next-heading) (point-max)))))
  	(if (bh/is-project-p)
  	    (let* ((subtree-end (save-excursion (org-end-of-subtree t)))
  		   (has-next ))
  	      (save-excursion
  		(forward-line 1)
  		(while (and (not has-next) (< (point) subtree-end) (re-search-forward "^\\*+ NEXT " subtree-end t))
  		  (unless (member "WAITING" (org-get-tags-at))
  		    (setq has-next t))))
  	      (if has-next
  		  nil
  		next-headline)) ; a stuck project, has subtasks but no next task
  	  nil))))

  (defun bh/skip-non-stuck-projects ()
    "Skip trees that are not stuck projects"
    ;; (bh/list-sublevels-for-projects-indented)
    (save-restriction
      (widen)
      (let ((next-headline (save-excursion (or (outline-next-heading) (point-max)))))
  	(if (bh/is-project-p)
  	    (let* ((subtree-end (save-excursion (org-end-of-subtree t)))
  		   (has-next ))
  	      (save-excursion
  		(forward-line 1)
  		(while (and (not has-next) (< (point) subtree-end) (re-search-forward "^\\*+ NEXT " subtree-end t))
  		  (unless (member "WAITING" (org-get-tags-at))
  		    (setq has-next t))))
  	      (if has-next
  		  next-headline
  		nil)) ; a stuck project, has subtasks but no next task
  	  next-headline))))

  (defun bh/skip-non-projects ()
    "Skip trees that are not projects"
    ;; (bh/list-sublevels-for-projects-indented)
    (if (save-excursion (bh/skip-non-stuck-projects))
  	(save-restriction
  	  (widen)
  	  (let ((subtree-end (save-excursion (org-end-of-subtree t))))
  	    (cond
  	     ((bh/is-project-p)
  	      nil)
  	     ((and (bh/is-project-subtree-p) (not (bh/is-task-p)))
  	      nil)
  	     (t
  	      subtree-end))))
      (save-excursion (org-end-of-subtree t))))

  (defun bh/skip-non-tasks ()
    "Show non-project tasks.
  Skip project and sub-project tasks, habits, and project related tasks."
    (save-restriction
      (widen)
      (let ((next-headline (save-excursion (or (outline-next-heading) (point-max)))))
  	(cond
  	 ((bh/is-task-p)
  	  nil)
  	 (t
  	  next-headline)))))

  (defun bh/skip-project-trees-and-habits ()
    "Skip trees that are projects"
    (save-restriction
      (widen)
      (let ((subtree-end (save-excursion (org-end-of-subtree t))))
  	(cond
  	 ((bh/is-project-p)
  	  subtree-end)
  	 ((org-is-habit-p)
  	  subtree-end)
  	 (t
  	  nil)))))

  (defun bh/skip-projects-and-habits-and-single-tasks ()
    "Skip trees that are projects, tasks that are habits, single non-project tasks"
    (save-restriction
      (widen)
      (let ((next-headline (save-excursion (or (outline-next-heading) (point-max)))))
  	(cond
  	 ((org-is-habit-p)
  	  next-headline)
  	 ((and bh/hide-scheduled-and-waiting-next-tasks
  	       (member "WAITING" (org-get-tags-at)))
  	  next-headline)
  	 ((bh/is-project-p)
  	  next-headline)
  	 ((and (bh/is-task-p) (not (bh/is-project-subtree-p)))
  	  next-headline)
  	 (t
  	  nil)))))

  (defun bh/skip-project-tasks-maybe ()
    "Show tasks related to the current restriction.
  When restricted to a project, skip project and sub project tasks, habits, NEXT tasks, and loose tasks.
  When not restricted, skip project and sub-project tasks, habits, and project related tasks."
    (save-restriction
      (widen)
      (let* ((subtree-end (save-excursion (org-end-of-subtree t)))
  	     (next-headline (save-excursion (or (outline-next-heading) (point-max))))
  	     (limit-to-project (marker-buffer org-agenda-restrict-begin)))
  	(cond
  	 ((bh/is-project-p)
  	  next-headline)
  	 ((org-is-habit-p)
  	  subtree-end)
  	 ((and (not limit-to-project)
  	       (bh/is-project-subtree-p))
  	  subtree-end)
  	 ((and limit-to-project
  	       (bh/is-project-subtree-p)
  	       (member (org-get-todo-state) (list "NEXT")))
  	  subtree-end)
  	 (t
  	  nil)))))

  (defun bh/skip-project-tasks ()
    "Show non-project tasks.
  Skip project and sub-project tasks, habits, and project related tasks."
    (save-restriction
      (widen)
      (let* ((subtree-end (save-excursion (org-end-of-subtree t))))
  	(cond
  	 ((bh/is-project-p)
  	  subtree-end)
  	 ((org-is-habit-p)
  	  subtree-end)
  	 ((bh/is-project-subtree-p)
  	  subtree-end)
  	 (t
  	  nil)))))

  (defun bh/skip-non-project-tasks ()
    "Show project tasks.
  Skip project and sub-project tasks, habits, and loose non-project tasks."
    (save-restriction
      (widen)
      (let* ((subtree-end (save-excursion (org-end-of-subtree t)))
  	     (next-headline (save-excursion (or (outline-next-heading) (point-max)))))
  	(cond
  	 ((bh/is-project-p)
  	  next-headline)
  	 ((org-is-habit-p)
  	  subtree-end)
  	 ((and (bh/is-project-subtree-p)
  	       (member (org-get-todo-state) (list "NEXT")))
  	  subtree-end)
  	 ((not (bh/is-project-subtree-p))
  	  subtree-end)
  	 (t
  	  nil)))))

  (defun bh/skip-projects-and-habits ()
    "Skip trees that are projects and tasks that are habits"
    (save-restriction
      (widen)
      (let ((subtree-end (save-excursion (org-end-of-subtree t))))
  	(cond
  	 ((bh/is-project-p)
  	  subtree-end)
  	 ((org-is-habit-p)
  	  subtree-end)
  	 (t
  	  nil)))))

  (defun bh/skip-non-subprojects ()
    "Skip trees that are not projects"
    (let ((next-headline (save-excursion (outline-next-heading))))
      (if (bh/is-subproject-p)
  	  nil
  	next-headline)))

  (defun bh/skip-non-archivable-tasks ()
    "Skip trees that are not available for archiving"
    (save-restriction
      (widen)
      ;; Consider only tasks with done todo headings as archivable candidates
      (let ((next-headline (save-excursion (or (outline-next-heading) (point-max))))
  	    (subtree-end (save-excursion (org-end-of-subtree t))))
  	(if (member (org-get-todo-state) org-todo-keywords-1)
  	    (if (member (org-get-todo-state) org-done-keywords)
  		(let* ((daynr (string-to-int (format-time-string "%d" (current-time))))
  		       (a-month-ago (* 60 60 24 (+ daynr 1)))
  		       (last-month (format-time-string "%Y-%m-" (time-subtract (current-time) (seconds-to-time a-month-ago))))
  		       (this-month (format-time-string "%Y-%m-" (current-time)))
  		       (subtree-is-current (save-excursion
  					     (forward-line 1)
  					     (and (< (point) subtree-end)
  						  (re-search-forward (concat last-month "\\|" this-month) subtree-end t)))))
  		  (if subtree-is-current
  		      subtree-end ; Has a date in this month or last month, skip it
  		    nil))  ; available to archive
  	      (or subtree-end (point-max)))
  	  next-headline))))


  ;; Archiving monthly works well for me. I keep completed tasks around for at least 30 days before archiving them. This keeps current clocking information for the last 30 days out of the archives. This keeps my files that contribute to the agenda fairly current (this month, and last month, and anything that is unfinished). I only rarely visit tasks in the archive when I need to pull up ancient history for something.

  ;; Archiving keeps my main working files clutter-free. If I ever need the detail for the archived tasks they are available in the appropriate archive file.


  (setq org-archive-mark-done nil)
  (setq org-archive-location (expand-file-name "%s_archive::* Archived Tasks" org-directory))       

  (setq diary-file (expand-file-name "diary" org-directory))

  ;; (setq org-refile-use-outline-path 'file)

  (setq org-use-speed-commands t)

  (setq org-agenda-tag-filter-preset (quote ("-drill")))

  ;; Keep tasks with dates on the global todo lists
  ;; (setq org-agenda-todo-ignore-with-date nil)

  ;; Keep tasks with deadlines on the global todo lists
  ;; (setq org-agenda-todo-ignore-deadlines nil)

  ;; Keep tasks with scheduled dates on the global todo lists
  ;; (setq org-agenda-todo-ignore-scheduled nil)

  ;; Keep tasks with timestamps on the global todo lists
  ;; (setq org-agenda-todo-ignore-timestamp nil)

  ;; Remove completed deadline tasks from the agenda view
  (setq org-agenda-skip-deadline-if-done t)

  ;; Remove completed scheduled tasks from the agenda view
  (setq org-agenda-skip-scheduled-if-done t)
  
  ;; Remove completed items from search results
  (setq org-agenda-skip-timestamp-if-done t)       
  ;; Compact blocks
  (setq org-agenda-compact-mode t)       
  (setq org-enforce-todo-dependencies t)

  (setq org-agenda-sticky t)

  ;; Always hilight the current agenda line
  (add-hook 'org-agenda-mode-hook
	    '(lambda () (hl-line-mode 1))
	    'append)

  ;; The following custom-set-faces create the highlights
  ;; (custom-set-faces
  ;;  ;; custom-set-faces was added by Custom.
  ;;  ;; If you edit it by hand, you could mess it up, so be careful.
  ;;  ;; Your init file should contain only one such instance.
  ;;  ;; If there is more than one, they won't work right.
  ;;  '(org-mode-line-clock ((t (:background "grey75" :foreground "red" :box (:line-width -1 :style released-button)))) t))              

  ;; (require-package 'org-plus-contrib)
  ;; (require-package 'ob-go)      
  ;; (require-package 'ob-restclient)
  ;; (require-package 'ob-html-chrome)
  ;; (require-package 'ob-typescript);
  ;; (require-package 'ob-tmux)
  ;; (org-babel-do-load-languages
  ;;  'org-babel-load-languages
  ;;  '((ledger . t)
  ;;    (plantuml . t)
  ;;    (python . t)
  ;;    (C . t)
  ;;    (js . t)
  ;;    (calc . t)
  ;;    (go . t)
  ;;    (css . t)
  ;;    (ditaa . t)
  ;;    (shell . t)
  ;;    (screen . t)
  ;;    (html-chrome . t)
  ;;    (ruby . t)
  ;;    (io . t)
  ;;    (org . t)
  ;;    (restclient . t)
  ;;    (sass . t)
  ;;    (gnuplot . t)
  ;;    (css . t)
  ;;    (makefile . t)
  ;;    (java . t)
  ;;    (typescript . t)
  ;;    (tmux . t)
  ;;    (emacs-lisp . t)))

  ;; Show all future entries for repeating tasks
  (setq org-agenda-repeating-timestamp-show-all t)

  ;; Show all agenda dates - even if they are empty
  (setq org-agenda-show-all-dates t)

  ;; Sorting order for tasks on the agenda
  (setq org-agenda-sorting-strategy
        (quote ((agenda habit-down time-up user-defined-up effort-up category-keep)
                (todo category-up effort-up)
                (tags category-up effort-up)
                (search category-up))))

  ;; Start the weekly agenda on Monday
  (setq org-agenda-start-on-weekday 1)

  (setq org-agenda-time-grid
        (quote
         ((daily today remove-match)
          (900 1100 1300 1500 1700)
          "......" "----------------")))

  ;; Enable display of the time grid so we can see the marker for the current time
  ;; (setq org-agenda-time-grid (quote ((daily today remove-match)
  ;;                                    #("----------------" 0 16 (org-heading t))
  ;;                                    (0900 1100 1300 1500 1700))))

  ;; Display tags farther right
  (setq org-agenda-tags-column -102)

  ;;
  ;; Agenda sorting functions
  ;;
  (setq org-agenda-cmp-user-defined 'bh/agenda-sort)

  (defun bh/agenda-sort (a b)
    "Sorting strategy for agenda items.
  Late deadlines first, then scheduled, then non-late deadlines"
    (let (result num-a num-b)
      (cond
  					; time specific items are already sorted first by org-agenda-sorting-strategy
       
  					; non-deadline and non-scheduled items next
       ((bh/agenda-sort-test 'bh/is-not-scheduled-or-deadline a b))
       
  					; deadlines for today next
       ((bh/agenda-sort-test 'bh/is-due-deadline a b))
       
  					; late deadlines next
       ((bh/agenda-sort-test-num 'bh/is-late-deadline '> a b))
       
  					; scheduled items for today next
       ((bh/agenda-sort-test 'bh/is-scheduled-today a b))
       
  					; late scheduled items next
       ((bh/agenda-sort-test-num 'bh/is-scheduled-late '> a b))
       
  					; pending deadlines last
       ((bh/agenda-sort-test-num 'bh/is-pending-deadline '< a b))
       
  					; finally default to unsorted
       (t (setq result nil)))
      result))

  (defmacro bh/agenda-sort-test (fn a b)
    "Test for agenda sort"
    `(cond
  					; if both match leave them unsorted
      ((and (apply ,fn (list ,a))
            (apply ,fn (list ,b)))
       (setq result nil))
  					; if a matches put a first
      ((apply ,fn (list ,a))
       (setq result -1))
  					; otherwise if b matches put b first
      ((apply ,fn (list ,b))
       (setq result 1))
  					; if none match leave them unsorted
      (t nil)))

  (defmacro bh/agenda-sort-test-num (fn compfn a b)
    `(cond
      ((apply ,fn (list ,a))
       (setq num-a (string-to-number (match-string 1 ,a)))
       (if (apply ,fn (list ,b))
           (progn
             (setq num-b (string-to-number (match-string 1 ,b)))
             (setq result (if (apply ,compfn (list num-a num-b))
                              -1
                            1)))
         (setq result -1)))
      ((apply ,fn (list ,b))
       (setq result 1))
      (t nil)))

  (defun bh/is-not-scheduled-or-deadline (date-str)
    (and (not (bh/is-deadline date-str))
         (not (bh/is-scheduled date-str))))

  (defun bh/is-due-deadline (date-str)
    (string-match "Deadline:" date-str))

  (defun bh/is-late-deadline (date-str)
    (string-match "\\([0-9]*\\) d\. ago:" date-str))

  (defun bh/is-pending-deadline (date-str)
    (string-match "In \\([^-]*\\)d\.:" date-str))

  (defun bh/is-deadline (date-str)
    (or (bh/is-due-deadline date-str)
        (bh/is-late-deadline date-str)
        (bh/is-pending-deadline date-str)))

  (defun bh/is-scheduled (date-str)
    (or (bh/is-scheduled-today date-str)
        (bh/is-scheduled-late date-str)))

  (defun bh/is-scheduled-today (date-str)
    (string-match "Scheduled:" date-str))

  (defun bh/is-scheduled-late (date-str)
    (string-match "Sched\.\\(.*\\)x:" date-str))



					; Use full outline paths for refile targets - we file directly with IDO
  (setq org-refile-use-outline-path 'file)

					; Targets complete directly with IDO
  (setq org-outline-path-complete-in-steps nil)

					; Allow refile to create parent tasks with confirmation
  (setq org-refile-allow-creating-parent-nodes (quote confirm))

					; Use IDO for both buffer and file completion and ido-everywhere to t
  (setq org-completion-use-ido t)
  ;; (setq ido-everywhere t)
  (setq ido-max-directory-size 100000)
  (ido-mode (quote both))
					; Use the current window when visiting files and buffers with ido
  (setq ido-default-file-method 'selected-window)
  (setq ido-default-buffer-method 'selected-window)
					; Use the current window for indirect buffer display
  (setq org-indirect-buffer-display 'current-window)

  ;; Refile settings
  ;; Exclude DONE state tasks from refile targets
  (defun bh/verify-refile-target ()
    "Exclude todo keywords with a done state from refile targets"
    (not (member (nth 2 (org-heading-components)) org-done-keywords)))

  (setq org-refile-target-verify-function 'bh/verify-refile-target)

  ;; Refile targets
  (setq org-refile-targets `((,(expand-file-name "gtd.org" org-directory) :maxlevel . 3)
                             (,(expand-file-name "tickler.org" org-directory) :level . 1)
                             (,(expand-file-name "someday.org" org-directory) :maxlevel . 2)))



  ;; Agenda files
  (setq org-agenda-files (list
                          (expand-file-name "inbox.org" org-directory)
                          (expand-file-name "gtd.org" org-directory)
                          (expand-file-name "tickler.org" org-directory)))       

  (setq org-tag-alist '((:startgrouptag)
                        (:grouptags) ("@work" . ?w) ("@home" . ?h) ("@outdoor" . ?o) (:endgrouptag)
                        (:grouptags) ("@high" . ?h) ("@medium" . ?m) ("@low" . ?l) (:endgrouptag)
                        (:grouptags) ("crypt" . ?E) ("@lifestyle" . ?l) ("@vocabulary" . ?v) ("@programming" . ?p) (:endgrouptag)
                        (:grouptags) ("WAITING" . ?W) ("HOLD" . ?H) ("CANCELLED" . ?C)  ("FLAGGED" . ?F) ("WORK" . ?X) ("PERSONAL" . ?P) ("NOTE" . ?N)))

  (setq org-todo-keyword-faces
        '(("TODO" :foreground "red" :weight bold)
          ("NEXT" :foreground "DarkOliveGreen1" :weight bold)
          ("PROGRESS" :foreground "tomato1" :weight bold)
          ("DONE" :foreground "forest green" :weight bold)
          ("WAITING" :foreground "orange" :weight bold)
          ("HOLD" :foreground "magenta" :weight bold)
          ("CANCELLED" :foreground "forest green" :weight bold)))

  (setq org-todo-state-tags-triggers
        '(("CANCELLED" ("CANCELLED" . t))
          ("WAITING" ("WAITING" . t))
          ("HOLD" ("WAITING") ("HOLD" . t))
          (done ("WAITING") ("HOLD"))
          ("TODO" ("WAITING") ("CANCELLED") ("HOLD"))
          ("NEXT" ("WAITING") ("CANCELLED") ("HOLD"))
          ("DONE" ("WAITING") ("CANCELLED") ("HOLD"))))

  (setq org-agenda-custom-commands '(("N" "Notes" tags "NOTE"
                                      ((org-agenda-overriding-header "Notes")
                                       (org-tags-match-list-sublevels t)))
                                     ("h" "Habits" tags-todo "STYLE=\"habit\""
                                      ((org-agenda-overriding-header "Habits")
                                       (org-agenda-sorting-strategy
                                        '(todo-state-down effort-up category-keep))))))
  

  ;;
  ;; Resume clocking task when emacs is restarted
  (org-clock-persistence-insinuate)
  ;;
  ;; Show lot of clocking history so it's easy to pick items off the C-F11 list
  (setq org-clock-history-length 23)

;;   ;; "Move point to the parent (project) task if any"
;;   (save-restriction
;;     (widen)
;;     (let ((parent-task (save-excursion (org-back-to-heading 'invisible-ok) (point))))
;;       (while (org-up-heading-safe)
;;         (when (member (nth 2 (org-heading-components)) org-todo-keywords-1)
;;           (setq parent-task (point))))
;;       (goto-char parent-task)
;;       parent-task)))

;; (defun bh/punch-in (arg)
;;   "Start continuous clocking and set the default task to the
;;   selected task.  If no task is selected set the Organization task
;;   as the default task."
;;   (interactive "p")
;;   (setq bh/keep-clock-running t)
;;   (if (equal major-mode 'org-agenda-mode)
;;       ;;
;;       ;; We're in the agenda
;;       ;;
;;       (let* ((marker (org-get-at-bol 'org-hd-marker))
;;              (tags (org-with-point-at marker (org-get-tags-at))))
;;         (if (and (eq arg 4) tags)
;;             (org-agenda-clock-in '(16))
;;           (bh/clock-in-organization-task-as-default)))
;;     ;;
;;     ;; We are not in the agenda
;;     ;;
;;     (save-restriction
;;       (widen)
;;   					; Find the tags on the current task
;;       (if (and (equal major-mode 'org-mode) (not (org-before-first-heading-p)) (eq arg 4))
;;           (org-clock-in '(16))
;;         (bh/clock-in-organization-task-as-default)))))

;; (defun bh/punch-out ()
;;   (interactive)
;;   (setq bh/keep-clock-running nil)
;;   (when (org-clock-is-active)
;;     (org-clock-out))
;;   (org-agenda-remove-restriction-lock))

;; (defun bh/clock-in-default-task ()
;;   (save-excursion
;;     (org-with-point-at org-clock-default-task
;;       (org-clock-in))))

;; (defun bh/clock-in-parent-task ()
;;   "Move point to the parent (project) task if any and clock in"
;;   (let ((parent-task))
;;     (save-excursion
;;       (save-restriction
;;         (widen)
;;         (while (and (not parent-task) (org-up-heading-safe))
;;           (when (member (nth 2 (org-heading-components)) org-todo-keywords-1)
;;             (setq parent-task (point))))
;;         (if parent-task
;;             (org-with-point-at parent-task
;;               (org-clock-in))
;;           (when bh/keep-clock-running
;;             (bh/clock-in-default-task)))))))

;; (defvar bh/organization-task-id "eb155a82-92b2-4f25-a3c6-0304591af2f9")

;; (defun bh/clock-in-organization-task-as-default ()
;;   (interactive)
;;   (org-with-point-at (org-id-find bh/organization-task-id 'marker)
;;     (org-clock-in '(16))))

;; (defun bh/clock-out-maybe ()
;;   (when (and bh/keep-clock-running
;;              (not org-clock-clocking-in)
;;              (marker-buffer org-clock-default-task)
;;              (not org-clock-resolving-clocks-due-to-idleness))
;;     (bh/clock-in-parent-task)))

;; (add-hook 'org-clock-out-hook 'bh/clock-out-maybe 'append)       

;; (require 'org-id)
;; (defun bh/clock-in-task-by-id (id)
;;   "Clock in a task by id"
;;   (org-with-point-at (org-id-find id 'marker)
;;     (org-clock-in nil)))

;; (defun bh/clock-in-last-task (arg)
;;   "Clock in the interrupted task if there is one
;;   Skip the default task and get the next one.
;;   A prefix arg forces clock in of the default task."
;;   (interactive "p")
;;   (let ((clock-in-to-task
;;          (cond
;;           ((eq arg 4) org-clock-default-task)
;;           ((and (org-clock-is-active)
;;                 (equal org-clock-default-task (cadr org-clock-history)))
;;            (caddr org-clock-history))
;;           ((org-clock-is-active) (cadr org-clock-history))
;;           ((equal org-clock-default-task (car org-clock-history)) (cadr org-clock-history))
;;           (t (car org-clock-history)))))
;;     (widen)
;;     (org-with-point-at clock-in-to-task
;;       (org-clock-in nil))))
        
;;   ;;  I always check that I haven't created task overlaps when fixing time clock entries by viewing them with log mode on in the agenda. There is a new view in the agenda for this – just hit v c in the daily agenda and clock gaps and overlaps are identified.

;;   ;; I want my clock entries to be as accurate as possible.

;;   ;; The following setting shows 1 minute clocking gaps. 

(setq org-time-stamp-rounding-minutes (quote (1 1)))

(setq org-agenda-clock-consistency-checks
      (quote (:max-duration "4:00"
                            :min-duration 0
                            :max-gap 0
                            j			    :gap-ok-around ("4:00"))))

;;   ;; Sometimes I change tasks I'm clocking quickly - this removes clocked tasks with 0:00 duration
(setq org-clock-out-remove-zero-time-clocks t)       

(setq org-columns-default-format "%80ITEM(Task) %10Effort(Effort){:} %10CLOCKSUM")
;; (setq org-columns-default-format "%81ITEM(Task) %10EffortDate: Tue, 10 Sep 2019 14:49:23 +0530
(setq org-global-properties (quote (("Effort_ALL" . "0:15 0:30 0:45 1:00 2:00 3:00 4:00 5:00 6:00 7:00 8:00 9:00 9:30")
                                    ("STYLE_ALL" . "habit"))))

;;   ;; Agenda clock report parameters
;;   (setq org-agenda-clockreport-parameter-plist
;;         (quote (:link t :maxlevel 5 :fileskip0 t :compact t :narrow 80)))

;;   (require 'org-protocol)

;;   ;; Standard key bindings


;;   (if (> (string-to-number (org-version)) 9.1)
;;       (require 'org-tempo))

;;   (defun bh/hide-other ()
;;     (interactive)
;;     (save-excursion
;;       (org-back-to-heading 'invisible-ok)
;;       (hide-other)
;;       (org-cycle)
;;       (org-cycle)
;;       (org-cycle)))

;;   (defun bh/set-truncate-lines ()
;;     "Toggle value of truncate-lines and refresh window display."
;;     (interactive)
;;     (setq truncate-lines (not truncate-lines))
;;     ;; now refresh window display (an idiom from simple.el):
;;     (save-excursion
;;       (set-window-start (selected-window)
;;                         (window-start (selected-window)))))

;;   (defun bh/make-org-scratch ()
;;     (interactive)
;;     (find-file "/tmp/publish/scratch.org")
;;     (gnus-make-directory "/tmp/publish"))

;;   (defun bh/switch-to-scratch ()
;;     (interactive)
;;     (switch-to-buffer "*scratch*"))
;;   (defun generate-random-password-for-template ()
;;     (let* ((title (read-from-minibuffer "Post Title: ")) ;Prompt to enter the post title
;;            (fname (org-hugo-slug title))
;;            (mapconcat #'identity
;;                       `(,(concat "* TODO " title)
;;                         ":PROPERTIES:"
;;                         ,(concat ":EXPORT_HUGO_BUNDLE: " fname)
;;                         ":EXPORT_FILE_NAME: index"
;;                         ":END:"
;;                         "%?\n")                ;Place the cursor here finally
;;                       "\n"))))

;;   (defun capture-password ()
;;     (concat "* %^{Name} :crypt: \n " (replace-regexp-in-string "\n" "" (shell-command-to-string "pwgen -ncsy 15 1"))))

;;   (defun capture-pin ()
;;     (setq pin/length (read-string "Length: "))
;;     (setq pin/commmand (concat "python -c " "'from random import randint;" "print(randint(" (number-to-string (expt 10 (- (string-to-number pin/length) 1))) "," (number-to-string (- (expt 10 (string-to-number pin/length)) 1)) "))'"))
;;     (concat "* %^{Name} :crypt: \n  " (replace-regexp-in-string "\n" "" (shell-command-to-string pin/commmand))))

(require 'epa-file)
(setq epa-pinentry-mode 'loopback)
(setq epa-file-encrypt-to (substring (shell-command-to-string "git config --global --get user.gpg") 0 -1))

(setq epa-file-select-keys nil)
(require 'org-crypt)
;; (require 'org-drill)
;; (require 'org-bullets)
;; Encrypt before save
(org-crypt-use-before-save-magic)
;; Encrypt todo's which is having crypt tag
(setq org-tags-exclude-from-inheritance (quote ("crypt")))

(setq org-crypt-key "virtualxi99@gmail.com")


;; Mark in dairy
(setq calendar-mark-diary-entries-flag t)

;; Appointment settings
(require 'appt)
(setq appt-time-msg-list nil
      appt-display-diary nil
      appt-display-interval (quote 5)
      appt-display-format (quote window)
      appt-message-warning-time (quote 15)
      appt-display-mode-line nil)
(appt-activate t)
(display-time)

;; Bind org-agenda-to-appt to hook
;; (add-hook (quote org-agenda-finalize-hook)
;;           (quote org-agenda-to-appt)
;;           (org-agenda-columns))

;; Include events from diary
(setq org-agenda-include-diary t)


(setq org-capture-templates `(
                              ("t" "TODO" entry (file+headline ,(expand-file-name "inbox.org" org-directory) "TASKS")
                               "* TODO %i%?")
                              ("T" "TICKLER" entry (file+headline ,(expand-file-name "tickler.org" org-directory) "TICKLER")
                               "* %i%?%U")
                              ;; ("a" "ARTICLE" plain (file capture-article-file)
                              ;;  "#+TITLE: %^{Title}\n#+DATE: %<%Y-%m-%d>")
                              ;; ("r", "PASSWORD" entry (file+headline ,(expand-file-name "tickler.org" org-directory) "SECRETS")
                              ;;  (function capture-password))
                              ;; ("b", "BANK" entry (file+headline ,(expand-file-name "tickler.org" org-directory) "SECRETS")
                              ;;  (function capture-pin))
                              ("o", "OBSERVATIONS" entry (file+headline ,(expand-file-name "tickler.org" org-directory) "OBSERVATIONS")
                               "* %^{Title} :@note:\n** %^{Description}")
                              ("v" "VOCABULARY" entry (file+headline ,(expand-file-name "tickler.org" org-directory) "VOCABULARY")
                               "* %^{Word} :drill:@note:@vocabulary: \n %t\n %^{Extended word (may be empty)} \n** Answer: \n%^{The definition}")
                              ("f" "FIXNEEDED" entry (file+headline ,(expand-file-name "tickler.org" org-directory) "FIX NEEDED")
                               "* %^{Subject} :@issue: \n** %^{Description}")
                              ("n" "NOTES" entry (file+headline ,(expand-file-name "tickler.org" org-directory) "NOTES")
                               "* %^{Title} :@note: \n** %^{Description}")
                              ("q" "QUESTIONS" entry (file+headline ,(expand-file-name "tickler.org" org-directory) "QUESTIONS")
                               "* %^{Title} :drill:@question: \n  %^{Question} \n** Answer: \n   %^{Answer}")
                              ("p" "PROTOCOL" entry (file+headline ,(expand-file-name "tickler.org" org-directory) "INBOX")
                               "* %^{Title}\nSource: %u, %c\n #+BEGIN_QUOTE\n%i\n#+END_QUOTE\n\n\n%?")
                              ("L" "PROTOCOL LINK" entry (file+headline ,(expand-file-name "tickler.org" org-directory) "INBOX")
                               "* %?[[%:link][%:description]] \nCaptured on: %U")))

(add-hook (quote org-after-todo-statistics-hook) (lambda (n-done n-not-done)
                                                   (let (org-log-done org-log-states)   ; turn off logging
                                                     (org-todo (if (= n-not-done 0) "DONE" "TODO")))))

(defun generate-password ()
  (interactive)
  (let ((x (shell-command-to-string "pwgen -y 15 1")))
    (insert x)))

;; (add-hook 'org-capture-mode-hook (lambda ()
;;                                    (local-set-key (kbd "C-c p") 'generate-password)))

;; (defun harshaqq/org-mode-hook ()
;;   (require 'org-bullets)  
;;   (org-bullets-mode)
;;   (flyspell-mode 1)
;;   (org-tempo-setup))

;; (defun harshaqq/org-capture-mode-hook ()
;;   (org-bullets-mode))

;; (add-hook 'org-capture-mode-hook 'harshaqq/org-capture-mode-hook)
;; (add-hook 'org-mode-hook 'harshaqq/org-mode-hook)

(add-hook 'org-shiftup-final-hook 'windmove-up)
(add-hook 'org-shiftleft-final-hook 'windmove-left)
(add-hook 'org-shiftdown-final-hook 'windmove-down)
(add-hook 'org-shiftright-final-hook 'windmove-right)

(require 'org-protocol)

(when (boundp 'org-plantuml-jar-path)
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((plantuml . t))))

(add-hook 'org-babel-after-execute-hook #'org-redisplay-inline-images)

(defun /org/org-mode-hook ()
  (toggle-truncate-lines t)
  (setq show-trailing-whitespace t))
(add-hook 'org-mode-hook #'/org/org-mode-hook)

(require-package 'ob-async)
(require 'ob-async)

(require-package 'org-bullets)
(setq org-bullets-bullet-list '("●" "○" "◆" "◇" "▸"))
(add-hook 'org-mode-hook #'org-bullets-mode)

(after 'ob-plantuml
  (when (executable-find "npm")
    (let ((default-directory (concat user-emacs-directory "/extra/plantuml-server/")))
      (unless (file-exists-p "node_modules/")
        (shell-command "npm install"))

      (ignore-errors
        (let ((kill-buffer-query-functions nil))
          (kill-buffer "*plantuml-server*")))
      (start-process "*plantuml-server*" "*plantuml-server*" "npm" "start"))

    (defun init-org/generate-diagram (uml)
      (let ((url-request-method "POST")
            (url-request-extra-headers '(("Content-Type" . "text/plain")))
            (url-request-data uml))
        (let* ((buffer (url-retrieve-synchronously "http://localhost:8182/svg")))
          (with-current-buffer buffer
            (goto-char (point-min))
            (search-forward "\n\n")
            (buffer-substring (point) (point-max))))))

    (defun org-babel-execute:plantuml (body params)
      (let* ((out-file (or (cdr (assoc :file params))
                           (error "PlantUML requires a \":file\" header argument"))))
        (let ((png (init-org/generate-diagram (concat "@startuml\n" body "\n@enduml"))))
          (with-temp-buffer
            (insert png)
            (write-file out-file)))))))

(provide 'config-org)
