;; package management
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))
(package-initialize)

;; My own custom stuff
(add-to-list 'load-path "~/projects/emacs-conf/")

;; Some niceties
(load-theme 'wombat)               ; load theme
(setq frame-title-format "%b")     ; set frame title to file name
(setq inhibit-startup-message t)   ; turn off splash screen
(setq initial-scratch-message "")  ; turn off initial scratch buffer message
(menu-bar-mode 0)                  ; turn off unnecessary UI
(defalias 'yes-or-no-p 'y-or-n-p)  ; make yes/no less annoying
(show-paren-mode t)                ; enable paren-matching
(transient-mark-mode t)            ; make regions sane

;; basic colors (for GUIs and evil terminals)
(set-background-color "black")
(set-foreground-color "green")
(set-face-foreground 'region "white")
(set-face-background 'region "SkyBlue4")

;; rebind incremental search to regex
(global-set-key [(control s)] 'isearch-forward-regexp)
(global-set-key [(control r)] 'isearch-backward-regexp)
(global-set-key [(meta %)] 'query-replace-regexp)

;; window management
(global-set-key [(control o)] 'other-window)

;; type brackets in pairs
(global-set-key (kbd "[") 'skeleton-pair-insert-maybe)
(global-set-key (kbd "(") 'skeleton-pair-insert-maybe)
(global-set-key (kbd "{") 'skeleton-pair-insert-maybe)
(global-set-key (kbd "\"") 'skeleton-pair-insert-maybe)
(setq skeleton-pair t)

;; highlight the current line
(setq highlight-current-line-globally t)
(require 'highlight-current-line)
(highlight-current-line-set-bg-color "dark slate gray")

;; load IDO for quick file/buffer switching
(require 'ido)
(ido-mode t)
(setq confirm-nonexistent-file-or-buffer nil)
(setq ido-create-new-buffer 'always)

;; customize isearch to always end at the beginning of search word
(add-hook 'isearch-mode-end-hook 'my-goto-match-beginning)
(defun my-goto-match-beginning ()
  (when (and isearch-forward isearch-other-end)
    (goto-char isearch-other-end)))
(defadvice isearch-exit (after my-goto-match-beginning activate)
  "Go to beginning of match."
  (when (and isearch-forward isearch-other-end)
    (goto-char isearch-other-end)))

;; osx-specific instructions
(when (string-match "darwin" system-configuration)
  ;; make apple-command be the meta modifier
  (setq mac-command-modifier 'meta))

;; graphics mode specific instructions
(when (display-graphic-p)
  (tool-bar-mode 0)
  (scroll-bar-mode -1)
  ; prettify vertical border color
  (set-face-background 'vertical-border "gray")
  (set-face-foreground 'vertical-border
		       (face-background 'vertical-border)))

;; markdown mode (err, I do write a lot of markdown)
(autoload 'markdown-mode "markdown-mode"
   "Major mode for editing Markdown files" t)
(add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-mode))

;; "twitter" mode -- show burndown of 140 chars/peragraph (+ how many
;; 140 char sentences are written)
(defun paragraph-burndown-modeline-str ()
  (let* ((beg (save-excursion
		(move-to-left-margin)
		(forward-paragraph -1)
		(point)))
	 (end (save-excursion
		(move-to-left-margin)
		(forward-paragraph +1)
		(point)))
	 (pwidth (string-width (buffer-substring-no-properties beg end)))
	 (ntweets (/ pwidth 140))
	 (nchars (- 140 (% pwidth 140))))
    (if (zerop (string-width (thing-at-point 'line t)))
	"0x/140"
      (concat
       (format "%sx/" ntweets)
       (if (<= nchars 20)
	   (propertize (format "%s" nchars) 'face 'warning)
	 (format "%s" nchars))))))
(defun paragraph-burndown-modeline-hook ()
  (setq mode-line-format
	(append mode-line-format '((:eval (paragraph-burndown-modeline-str))))))
(add-hook 'markdown-mode-hook 'paragraph-burndown-modeline-hook)

