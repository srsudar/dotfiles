; SS: Much of this taken from:
; https://trac.yelpcorp.com/wiki/EmacsTips
;
; Congratulations! You're customizing your editor
(add-to-list 'load-path "~/.emacs.d/")

; And here we're going to turn on linum mode.
; The require statement is taken from here, where there is 
; lots of good info:
; http://www.cs.berkeley.edu/~prmohan/emacs/
(require 'linum)
(global-linum-mode t)

; Add all top-level subdirectories of .emacs.d to the load path
(progn (cd "~/.emacs.d")
       (normal-top-level-add-subdirs-to-load-path))
; Third party libraries are stored in ~/.emacs.d/extern
(add-to-list 'load-path "~/.emacs.d/extern")
(progn (cd "~/.emacs.d/extern")
       (normal-top-level-add-subdirs-to-load-path))

; use tabs in files (urgh...yelp!)
(setq-default indent-tabs-mode t)

; tab display width of 4 columns by default
; (throw everything at the wall, and eventually something will stick...)
(setq-default tab-width 4)  ; Normal emacs tab-width
; (setq-default c-basic-offset 2) ; python-mode.el setting
(setq-default py-indent-offset 4) ; Use Tabs, not spaces
(setq-default py-indent-offset 4) ; emacs-for-python setting
(setq-default py-smart-indentation nil) ; Don't try to guess tab width

(defun customize-py-tabs ()
    (setq tab-width 4
        py-indent-offset 4
        indent-tabs-mode t
        py-smart-indentation nil
        python-indent 4
    )
 )

(add-hook 'python-mode-hook 'customize-py-tabs)

; Store backups in their own directory instead of littering the
; whole filesystem with goddamn ~ files.
(setq
   backup-by-copying t ; don't clobber symlinks
   backup-directory-alist
    '(("." . "~/.emacs.d/emacs_backups")) ; don't litter my fs tree
   version-control t ; use versioned numbers for backup files
   kept-new-versions 6 ; number of newest versions to keep
   kept-old-versions 2 ; number of oldest versions to keep
   delete-old-versions t) ; delete excess backup versions silently


; Reconfigure whitespace-mode for day-to-day use
(require 'whitespace)
(setq whitespace-style '(face tabs space-before-tab tab-mark))
(global-whitespace-mode t)

(setq-default whitespace-line-column 80) ; defines what is "too long"

; This is like the lines-tail setting for whitespace-style
; Except it uses preprend, so it doesn't clobber other faces
(require 'whitespace)
(defface too-long-line
  '((t :background "gray14"))
  "Face for parts of a line that co over 80 chars."
)

; Can't remember where I stole this from. Similar code in whitespace.el
(add-hook 'font-lock-mode-hook (lambda ()
 (font-lock-add-keywords nil
   `((,(format
      "^\\([^\t\n]\\{%s\\}\\|[^\t\n]\\{0,%s\\}\t\\)\\{%d\\}%s\\(.+\\)$"
      tab-width (- tab-width 1)
      (/ whitespace-line-column tab-width)
      (let ((rem (% whitespace-line-column tab-width)))
        (if (zerop rem)
        ""
        (format ".\\{%d\\}" rem))))
     (2 'too-long-line prepend)))
   t)))

; And this will try to load the srsudar-python thing
; I've just made.
(load-library "srsudar-python")

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(linum ((t (:inherit (shadow default) :background "color-238" :foreground "yellow")))))
