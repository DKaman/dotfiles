;;; packages.el --- dired Layer packages File for Spacemacs
;;
;; This file is not part of GNU Emacs.
;;
;;; License: GPLv3

(defvar dired-packages '(dired+))

(defun dired/init-dired+ ()
  "Initialize `dired+'."

  (setq diredp-hide-details-initially-flag t)
  (use-package dired+)

  (after "dired-aux"
    (setq dired-free-space-args "-Ph")
    (setq dired-guess-shell-alist-user '(("\\.mp4$" "cvlc" "mplayer")
                                         ("\\.avi$" "cvlc" "mplayer")
                                         ("\\.mkv$" "cvlc" "mplayer")
                                         ("\\.pdf$" "evince" "zathura")
                                         ("\\.docx$" "open")
                                         ("\\.tar.bz2" "tar jxvf")
                                         ("\\.tar.gz" "tar xzvf")
                                         ("\\.*$" "open")))
    (add-to-list 'dired-compress-file-suffixes '("\\.zip$" "unzip")))
  (setq dired-listing-switches "-alhv")
  (setq dired-recursive-copies 'always)
  (after "ibuf-ext"
    (add-to-list 'ibuffer-saved-filter-groups
                 '("default" ("dired" (mode . dired-mode)))))

  ;; Allow running multiple async commands simultaneously
  (defadvice shell-command (after shell-in-new-buffer
                             (command &optional output-buffer error-buffer))
    (when (get-buffer "*Async Shell Command*")
      (with-current-buffer "*Async Shell Command*" (rename-uniquely))))
  (ad-activate 'shell-command)

  (evil-leader/set-key
    "d" (defun dired-here ()
          (interactive)
          (let ((cwd (file-name-directory (or (buffer-file-name) ""))))
            (cond
             ((and cwd (file-exists-p cwd))
              (dired cwd))
             (t
              (message "I'm not sure which dir to view."))))))

  (setq dired-dwim-target t)
  (after "dired"
    (define-key dired-mode-map (kbd "<right>") 'dired-find-alternate-file)
    (define-key dired-mode-map (kbd "<left>") (defun dired-find-parent-directory ()
                                                (interactive)
                                                (find-alternate-file "..")))

    (define-key dired-mode-map
      (vector 'remap 'beginning-of-buffer)
      (defun dired-back-to-top ()
        (interactive)
        (beginning-of-buffer)
        (search-forward "..")
        (dired-next-line 1)))

    (define-key dired-mode-map
      (vector 'remap 'end-of-buffer)
      (defun dired-jump-to-bottom ()
        (interactive)
        (end-of-buffer)
        (dired-next-line -1))))

  (defun kill-and-dired-jump ()
    (interactive)
    (let ((current-directory (file-name-directory buffer-file-name))
          (current-buffer (car (buffer-list))))
      (write-file buffer-file-name)
      (kill-buffer current-buffer)
      (dired current-directory)))

  (define-key evil-normal-state-map (kbd "ZZ") 'kill-and-dired-jump))
