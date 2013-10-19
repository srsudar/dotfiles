(load-file "~/.emacs.d/emacs-for-python/epy-init.el")
(epy-setup-ipython)
(epy-setup-checker "pyflakes %f")

; Pyflakes on the fly with flymake
(require 'flymake)
; Currently running into trouble loading
; flymake cursor, wil hopefully eventually get resolved.
;(require 'flymake-cursor)

(when (load "flymake" t)
(defun flymake-pylint-init ()
 (let* ((temp-file (flymake-init-create-temp-buffer-copy
                    'flymake-create-temp-inplace))
        (local-file (file-relative-name
                     temp-file
                     (file-name-directory buffer-file-name))))
   (list "pyflakes" (list local-file))))

(add-to-list 'flymake-allowed-file-name-masks
             '("\\.py\\'" flymake-pylint-init)))

; Load flymake on non-temp buffers
(add-hook 'python-mode-hook (lambda () (unless (eq buffer-file-name nil) (flymake-mode 1))))
