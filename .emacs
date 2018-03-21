
;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(package-initialize)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   (quote
    (rjsx-mode browse-kill-ring powershell lorem-ipsum mmm-mode rust-mode transpose-frame yaml-mode py-autopep8 magit jinja2-mode markdown-mode flycheck elpy material-theme better-defaults))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )


;; Install Packages
;; -----------------------------------------------------------------

;; From:
;; https://realpython.com/blog/python/emacs-the-best-python-editor/
(require 'package)

(add-to-list 'package-archives
	     '("melpa" . "http://melpa.org/packages/") t)

(package-initialize)
(when (not package-archive-contents)
  (package-refresh-contents))

;; Note: better-defaults loads ido-mode, which you'll probably wind up
;; confused by at some point.
(defvar myPackages
  '(better-defaults
    elpy
    material-theme
    flycheck
    py-autopep8
    yaml-mode
    markdown-mode
    transpose-frame
    magit))

(mapc #'(lambda (package)
	  (unless (package-installed-p package)
	    (package-install package)))
      myPackages)

(add-to-list 'load-path "~/.emacs.d/site-lisp")
(let ((default-directory "~/.emacs.d/site-lisp/"))
       (normal-top-level-add-subdirs-to-load-path))

(require 'hl-tags-mode)
(add-hook 'sgml-mode-hook (lambda () (hl-tags-mode 1)))
(add-hook 'nxml-mode-hook (lambda () (hl-tags-mode 1)))

;; Basic customization
;; -----------------------------------------------------------------
(setq inhibit-startup-message t) ;; hide the startup message
(load-theme 'material t) ;; load material theme
(global-linum-mode t) ;; enable line numbers globally
;; global auto revert mode
(global-auto-revert-mode t)


;; cleanup whitespace on kill-line
(defadvice kill-line (after kill-line-cleanup-whitespace activate compile)
  "cleanup whitespace on kill-line"
  (if (not (bolp))
      (delete-region (point) (progn (skip-chars-forward " \t") (point)))))


;; IDO
;; -----------------------------------------------------------------
(add-to-list 'ido-ignore-files "\\`__pycache__/")
;; Prevent ido from looking in other directories to autocomplete
;; filenames.
(setq ido-auto-merge-work-directories-length -1)

;; Elpy
;; ------------------------------------------------------------------
(elpy-enable) ;; better python mode
(setq elpy-rpc-backend "jedi")
;; Use flycheck instead of flymake
(when (require 'flycheck nil t)
  (setq elpy-modules (delq 'elpy-module-flymake elpy-modules))
  (add-hook 'elpy-mode-hook 'flycheck-mode))

(add-hook 'python-mode-hook
          (lambda () (add-to-list 'write-file-functions 'delete-trailing-whitespace)))

(setq elpy-rpc-python-command "python3")
(setq python-shell-interpreter "python3")

(require 'py-autopep8)
(add-hook 'elpy-mode-hook 'py-autopep8-enable-on-save)

;; Company mode is used for auto-completion. Turn it off because tab
;; completion is annoying.

(add-hook 'elpy-mode-hook (lambda () "Turn off company mode" (company-mode 0)))



;; Modes
;; -------------------------------------------------------------------
(add-to-list 'auto-mode-alist '("\\.md\\'" . gfm-mode))
;; Weird, but in practice if I'm editing an html file, it's a Jinja2 template.
(add-to-list 'auto-mode-alist '("\\.html\\'" . jinja2-mode))
;; CamelCase aware editing.
(add-hook 'prog-mode-hook 'subword-mode)

;; Yas
;; -------------------------------------------------------------------

;; Rebind yas. I use tab too often to want it to be expanding things.
;; From https://stackoverflow.com/questions/14066526/unset-tab-binding-for-yasnippet
;(yas-global-mode 1)

;; Strangely, just redefining one of the variations below won't work.
;; All rebinds seem to be needed.
(define-key yas-minor-mode-map [(tab)]        nil)
(define-key yas-minor-mode-map (kbd "TAB")    nil)
(define-key yas-minor-mode-map (kbd "<tab>")  nil)

;; The following is optional.
(define-key yas-minor-mode-map (kbd "C-x C-y")     'yas-expand)

;;
(add-hook 'js-mode-hook 'yas-minor-mode)

;; mmm-mode
;; ---------------------------------------------------------------------------

(require 'mmm-mode)
(setq mmm-global-mode 'maybe)
(setq mmm-parse-when-idle 't)

;; From http://jblevins.org/log/mmm
(defun my-mmm-markdown-auto-class (lang &optional submode)
  "Define a mmm-mode class for LANG in `markdown-mode' using SUBMODE.
If SUBMODE is not provided, use `LANG-mode' by default."
  (let ((class (intern (concat "markdown-" lang)))
        (submode (or submode (intern (concat lang "-mode"))))
        (front (concat "^```\s*" lang "[\n\r]+"))
        (back "^```"))
    (mmm-add-classes (list (list class :submode submode :front front :back back)))
    (mmm-add-mode-ext-class 'markdown-mode nil class)
    (mmm-add-mode-ext-class 'gfm-mode nil class)
    ))


;; Mode names that derive directly from the language name
(mapc 'my-mmm-markdown-auto-class
      '("awk" "bibtex" "c" "css" "html" "latex" "lisp" "makefile"
        "markdown" "python" "r" "ruby" "sql" "stata" "xml"))

(my-mmm-markdown-auto-class "cpp" 'c++-mode)
