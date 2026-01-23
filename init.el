;;; init -- Init file
;;; -*- lexical-binding: t -*-

;;; Commentary:

;; Emacs config file.  Everything is inside a use-package (except the initial blurb to bootstrap straight).  See
;; https://github.com/a13/emacs.d for inspiration

;; External dependencies:
;;   - Cascadia Code font: https://github.com/microsoft/cascadia-code/releases
;;     - For TUI operation, this is only needed on the terminal emulator and ligatures should be enabled. 
;;   - ag (the silver searcher)
;;     - It should be installed on the system running Emacs
;;   - The emacs-lsp-booster executable from https://github.com/blahgeek/emacs-lsp-booster
;;     - Sketchy executable from the internet.  It's only used once and can be safely removed.  Look for "booster" in
;;       this file. 
;;   - The fonts for all-the-icons
;;     - This is installed via an Emacs command (look up all-the-icons in M-x) and in TUI mode it is the responsibility
;;       of the terminal emulator to render these glyphs correctly (some already offer it semi out of the box,
;;       e.g. click a button to set up nerd fonts).


;;; Code:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Bootstrap straight.el
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; This is the only part that isn't a use-package directive.  This comes from
;; https://github.com/radian-software/straight.el?tab=readme-ov-file#bootstrapping-straightel
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name
        "straight/repos/straight.el/bootstrap.el"
        (or (bound-and-true-p straight-base-dir)
            user-emacs-directory)))
      (bootstrap-version 7))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))
(setq straight-use-package-by-default t)
(straight-use-package 'use-package)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Performance improvements
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; These are added early on so we can enjoy them while loading the rest of the file.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Garbage collector improvements
(use-package gcmh
  :demand t
  :config
  (gcmh-mode 1))

;; Potentially slightly improve startup time
(use-package fnhh
  :straight
  (:host github :repo "a13/fnhh")
  :config
  (fnhh-mode 1))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Changes affecting use-package itself
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Next up, we'll need these for some of the rest of use-package commands.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Add a custom-update keyword to use-package (see https://github.com/a13/use-package-custom-update)
(use-package use-package-custom-update
  :straight
  (:host github :repo "a13/use-package-custom-update"))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Base Emacs customizations
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Anything defined in the C code. These are all editor customizations.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package emacs
  :bind
  ("M-j" . delete-indentation)
  :custom
  (frame-resize-pixelwise t "Resize frames pixelwise, obviously")
  (default-frame-alist '((menu-bar-lines 0)
                         (tool-bar-lines 0)
                         (vertical-scroll-bars)
                         (width . 135)) "No menus, no tool bars, yes scroll bars, wider")
  (scroll-conservatively 101 "Scroll one line at at ime")
  (inhibit-startup-screen t "Don't show splash screen")
  (use-dialog-box nil "Disable dialog boxes even when using the mouse")
  (x-gtk-use-system-tooltips nil "Don't use the gtk flavor of tooltip")
  (enable-recursive-minibuffers t "Allow minibuffer commands in the minibuffer")
  (indent-tabs-mode nil "Spaces!")
  (tab-width 4 "And if tabs, 4 spaces wide")
  (debug-on-quit nil "Set this to t to enter the debugger on C-g")
  (fill-column 120 "line wrap after 120 columns")
  :custom-face
  (default ((t (:font "Cascadia Code")))))  ;; Use Cascadia Code font by default


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Editor customizations using either new or built-in packages
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; All of these are generic for any use of the editor, affecting either basic behaviors or stuff that isn't specific to
;; any use-case. These often need the `:straight nil` bit to work.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package frame
  :straight nil
  :bind
  ;; Disable suspending on C-z
  ("C-z" . nil))

(use-package ibuffer
  :bind
  ;; Remap list-buffers to use ibuffer instead
  ([remap list-buffers] . ibuffer))

(use-package files
  :straight nil
  :bind
  ;; I revert buffers often, so bind it
  ("C-c r" . revert-buffer)
  :hook
  ;; Cleanup whitespace on save
  (before-save . delete-trailing-whitespace)
  :custom
  ;; Add a newline right before the file is saved
  (require-final-newline t)
  ;; backup settings
  (backup-by-copying t)
  (backup-directory-alist
   `((".*" . ,(locate-user-emacs-file "backups"))))
  (delete-old-versions t)
  (kept-new-versions 6)
  (kept-old-versions 2)
  (version-control t))

;; We don't use Customize in this house
(use-package cus-edit
  :straight nil
  :defer t
  :custom
  (custom-file null-device "Don't store customizations"))

;; Use the forward style to uniquify buffer names that visit identically named files
(use-package uniquify
  :straight nil
  :defer 0.1
  :custom
  (uniquify-buffer-name-style 'forward))

;; Bind finding a file as root to C-x M-f
(use-package sudo-edit
  :config (sudo-edit-indicator-mode)
  :bind (:map ctl-x-map
              ("M-f" . sudo-edit)))

;; Get the user shell's PATH variable for Emacs to use
(use-package exec-path-from-shell
  :defer 0.1
  :config
  (when (string-equal (file-name-nondirectory shell-file-name) "sh")
    (setq exec-path-from-shell-shell-name "/bin/bash"))
  (exec-path-from-shell-initialize))

;; Almost smooth mouse scrolling
(use-package mwheel
  :straight nil
  :custom
  (mouse-wheel-scroll-amount '(1
                               ((shift) . 5)
                               ((control))))
  (mouse-wheel-progressive-speed nil))
(use-package pixel-scroll
  :straight nil
  :config
  (pixel-scroll-mode))

;; For files with very long lines, if they take a long time to load, stop and say "so long" to most major modes
(use-package so-long
  :config (global-so-long-mode))

;; indicate minibuffer depth
(use-package mb-depth
  :config
  (minibuffer-depth-indicate-mode 1))

;; blatant copy-paste, it makes ibuffer prettier
(use-package ibuffer-vc
  :defer t
  :config
  (define-ibuffer-column icon
    (:name "Icon" :inline t)
    (all-the-icons-ivy--icon-for-mode major-mode))
  :custom
  (ibuffer-formats
   '((mark modified read-only vc-status-mini " "
           (name 18 18 :left :elide)
           " "
           (size 9 -1 :right)
           " "
           (mode 16 16 :left :elide)
           " "
           filename-and-process)) "include vc status info")
  :hook
  (ibuffer . (lambda ()
               (ibuffer-vc-set-filter-groups-by-vc-root)
               (unless (eq ibuffer-sorting-mode 'alphabetic)
                 (ibuffer-do-sort-by-alphabetic)))))

;; kill unused buffers automatically
(use-package midnight
  :custom
  (clean-buffer-list-delay-general 5 "Five days before buffers are autokilled")
  (midnight-delay 3637 "Seconds after midnight when midnight will do its thing")
  (midnight-mode t "Enable midnight mode"))

;; move around windows with S-left/right/down/up
(use-package windmove
  :config
  (windmove-default-keybindings))

;; if you start typing when a region is selected, replace it with whatever you're typing
(use-package delsel
  :custom
  (delete-selection-mode 1))

;; If there is a URL under the point, browse it
(use-package browse-url
  :bind
  ("C-c u" . browse-url-at-point))

;; I like using vim-like commands to create new lines
(use-package crux
  :bind
  (("C-o" . crux-smart-open-line)
   ("C-S-o" . crux-smart-open-line-above)))

;; See the contents of the killing in their own buffer and pick and choose what to paste
(use-package browse-kill-ring
  :config
  (browse-kill-ring-default-keybindings))

(use-package xt-mouse
   :config
   (xterm-mouse-mode 1))

;; If I don't add this, eglot fails to load.
(use-package project)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Searching
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Searching within files, within emacs, searching for files... All things related to searching.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; An alternative to the usual M-x interface: counsel-M-x can use this one
(use-package amx :defer t)

;; ivy-mode ensures that any Emacs command using completing-read-function uses ivy for completion.
(use-package ivy
  :custom
  (ivy-count-format "%d/%d " "Show anzu-like counter")
  (ivy-use-selectable-prompt t "Make the prompt line selectable")
  :custom-face
  (ivy-current-match ((t (:inherit 'hl-line))))
  :config
  (ivy-mode t))
(use-package ivy-xref
  :defer t
  :custom
  (xref-show-xrefs-function #'ivy-xref-show-xrefs "Use Ivy to show xrefs"))

;; Set up counsel commands
(use-package counsel
  :init
  (counsel-mode))

;; Ivy completions have descriptions and stuff
(use-package ivy-rich
  :config
  (ivy-rich-project-root-cache-mode t)
  (ivy-rich-mode 1))

;; Use the silver searcher
(use-package ag
  :defer t
  :custom
  (ag-highlight-search t "Highlight the current search term."))

(use-package projectile
  :ensure t
  :init
  (projectile-mode +1)
  :custom
  (projectile-indexing-method 'hybrid)
  (projectile-sort-order 'recently-active)
  (projectile-enable-caching t)
  :bind
  (:map projectile-mode-map
        ("M-p" . projectile-command-map)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Eshell configurations
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Anything related to just eshell itself (some other sections include things that affect eshell but are related to that
;; section, such as completion)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package eshell
  :bind
  ;; easy access to open eshell
  ("C-c e" . eshell))

;; I can't find anything about em-smart, no clue what this does

(use-package em-smart
  :straight nil
  :defer t
  :config
  (eshell-smart-initialize)
  :custom
  (eshell-where-to-jump 'begin)
  (eshell-review-quick-commands nil)
  (eshell-smart-space-goes-to-end t))

;; This seems to enable help for eshell through eldoc...

(use-package esh-help
  :defer t
  :config
  (setup-esh-help-eldoc))

;; Autosuggest...

(use-package esh-autosuggest
  :hook (eshell-mode . esh-autosuggest-mode))

;; A nicer prompt

(use-package eshell-prompt-extras
  :after (eshell esh-opt)
  :custom
  (eshell-prompt-function #'epe-theme-dakrone))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; IDE customizations
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Any customizations that are exclusively related to coding without going into any specific language.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Highlight the current line in programming modes
(use-package hl-line
  :hook
  (prog-mode . hl-line-mode))

;; Highlight TODOs
(use-package hl-todo
  :custom-face
  (hl-todo ((t (:inherit hl-todo :italic t))))
  :hook ((prog-mode . hl-todo-mode)
         (yaml-mode . hl-todo-mode)))

;; Colorize parenthesis pairwise
(use-package rainbow-delimiters
  :hook
  (prog-mode . rainbow-delimiters-mode))

;; For git config files
(use-package git-modes
  :defer t)

;; Magit!
(use-package magit
  :bind
  (("C-c g" . magit-status)
   (:map magit-hunk-section-map ("RET" . magit-diff-visit-file-other-window))
   (:map magit-file-section-map ("RET" . magit-diff-visit-file-other-window))))

;; Walk through versions of a discrete file
(use-package git-timemachine
  :defer t)

;; For merge conflicts
(use-package smerge-mode
  :defer t)

;; Highlight changes from vc in buffer and dired
(use-package diff-hl
  :hook
  ((magit-post-refresh . diff-hl-magit-post-refresh)
   (prog-mode . diff-hl-mode)
   (org-mode . diff-hl-mode)
   (dired-mode . diff-hl-dired-mode)))

;; Show issues in the code (underlining it)
(use-package flycheck
  :hook
  (prog-mode . flycheck-mode))

;; Test coverage (if data available)
(use-package cov
  :defer t
  :custom
  (cov-coverage-mode t))

;; Highlight indentation
(use-package highlight-indentation
  :hook
  (prog-mode . highlight-indentation-mode))

;; Display line numbers
(use-package display-line-numbers
  :hook
  (prog-mode . display-line-numbers-mode))

;; Colors in compilation buffer
(use-package fancy-compilation
  :init
  (with-eval-after-load 'compile
    (fancy-compilation-mode)))

;; Jump to first error on compilation
(use-package compile
  :straight nil
  :config
  (setq compilation-scroll-output 'first-error))

;; Debugger -- I've known it to generate warnings on load some times...
(use-package realgud)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; LSP setup
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Anything needed to get LSP to work, either in general or for specific languages (as long as it's not too closely tied
;; to the language, use common sense).
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package eglot
  :straight nil
  :hook
  (prog-mode . eglot-ensure)
  :bind (:map eglot-mode-map ("C-c C-n")))

;; Make eglot a bit faster by offloading the effort of translating json to a lisp-like structure
(use-package eglot-booster
  :straight (eglot-booster
             :type git
             :host github
             :repo "jdtsmith/eglot-booster")
  :config (eglot-booster-mode))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Auto-completion
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Anything related to having completion work and be useful and cool
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package company
  :hook
  (after-init . global-company-mode))

;; Quickhelp if you linger in the completion
(use-package company-quickhelp
  :defer t
  :custom
  (company-quickhelp-delay 3)
  (company-quickhelp-mode 1))

;; Completion for eshell
(use-package company-shell
  :after company
  :defer t
  :custom-update
  (company-backends '(company-shell)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Markdown
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Customizations specific to the markdown major mode.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package markdown-mode)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Python
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Customizations specific to the python major mode.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Inline python comments should be two spaces away from code
(use-package newcomment
  :straight nil
  :hook
  (python-base-mode . (lambda () (set (make-local-variable 'comment-inline-offset) 2))))

;; Bind starting a python interpreter
(use-package python
  :bind
  ("C-c p" . run-python))

;; Bind running pytest
(use-package python-pytest
  :bind
  ("C-c y" . python-pytest-dispatch))

;; Prettier docstrings for python
(use-package python-docstring
  :hook
  (python-base-mode . python-docstring-mode))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Rust
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Customizations specific to the rust major mode.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package rust-mode)
(use-package cargo-mode
  :after rust-mode
  :hook
  (rust-mode . cargo-minor-mode)
  :custom
  (compilation-scroll-output t))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Go
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Customizations specific to the go major mode.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package go-mode)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Org
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Customizations for org-mode. I barely do note taking.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package calendar
  :defer t
  :custom
  (calendar-week-start-day 1))

(use-package org
  :straight nil
  :defer t
  :custom
  (org-adapt-indentation t)
  (org-src-tab-acts-natively t))

(use-package org-bullets
  :ensure t
  :hook
  (org-mode . org-bullets-mode))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Pretty stuff
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Themes, fonts, icons... Anything that makes Emacs look prettier. At the very end so I can easily notice if something
;; craps out earlier in the config because I'll see Emacs looks weird.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Enable ligatures, snippet from
;; https://github.com/mickeynp/ligature.el?tab=readme-ov-file#example-font-configuration-cascadia-code

(use-package ligature
  :config
  ;; Enable the "www" ligature in every possible major mode
  (ligature-set-ligatures 't '("www"))
  ;; Enable traditional ligature support in eww-mode, if the `variable-pitch' face supports it
  (ligature-set-ligatures 'eww-mode '("ff" "fi" "ffi"))
  ;; Enable all Cascadia Code ligatures in programming modes
  (ligature-set-ligatures 'prog-mode '("|||>" "<|||" "<==>" "<!--" "####" "~~>" "***" "||=" "||>"
                                       ":::" "::=" "=:=" "===" "==>" "=!=" "=>>" "=<<" "=/=" "!=="
                                       "!!." ">=>" ">>=" ">>>" ">>-" ">->" "->>" "-->" "---" "-<<"
                                       "<~~" "<~>" "<*>" "<||" "<|>" "<$>" "<==" "<=>" "<=<" "<->"
                                       "<--" "<-<" "<<=" "<<-" "<<<" "<+>" "</>" "###" "#_(" "..<"
                                       "..." "+++" "/==" "///" "_|_" "www" "&&" "^=" "~~" "~@" "~="
                                       "~>" "~-" "**" "*>" "*/" "||" "|}" "|]" "|=" "|>" "|-" "{|"
                                       "[|" "]#" "::" ":=" ":>" ":<" "$>" "==" "=>" "!=" "!!" ">:"
                                       ">=" ">>" ">-" "-~" "-|" "->" "--" "-<" "<~" "<*" "<|" "<:"
                                       "<$" "<=" "<>" "<-" "<<" "<+" "</" "#{" "#[" "#:" "#=" "#!"
                                       "##" "#(" "#?" "#_" "%%" ".=" ".-" ".." ".?" "+>" "++" "?:"
                                       "?=" "?." "??" ";;" "/*" "/=" "/>" "//" "__" "~~" "(*" "*)"
                                       "\\\\" "://"))
  ;; Enables ligature checks globally in all buffers. You can also do it per mode with `ligature-mode'.
  (global-ligature-mode t))

;; icons!

(use-package all-the-icons :defer t)

;; icons in dired!

(use-package all-the-icons-dired
  :hook
(dired-mode . all-the-icons-dired-mode))

;; icons in ivy!
(use-package all-the-icons-ivy
  :after ivy
  :custom
  (all-the-icons-ivy-buffer-commands '() "Don't use for buffers.")
  :config
  (all-the-icons-ivy-setup))

;; cool mode line inspired by doom emacs
(use-package mood-line
  :custom-face
  (mode-line ((t (:inherit default (:box (:line-width -1 :style released-button))))))
  :hook
  (after-init . mood-line-mode))

;; zenburn theme (at the very end so that if emacs looks weird, something went wrong with init!)

(use-package zenburn-theme
  :config
  (load-theme 'zenburn t))

;;; init.el ends here
