;;; early-init --- Early init file  -*- lexical-binding: t; -*-

;;; Commentary:

;; Early init file.  Minimal configurations that must be executed at early init.  Does not use the use-package discipline of init.el

;;; Code:

;; Ensure straight is the one loading our packages
(setq package-enable-at-startup nil)

;;; early-init.el ends here
