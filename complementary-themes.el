;;; complementary-themes.el --- Paired light and dark themes  -*- lexical-binding: t; -*-

;; Copyright (C) 2026
;; SPDX-License-Identifier: GPL-3.0-or-later
;; Version: 0.2.0
;; Package-Requires: ((emacs "29.1"))
;; Keywords: faces, themes

;;; Commentary:

;; Package entry point for configurations which load `complementary-themes'.
;; Theme definitions themselves remain available as `complementary-light' and
;; `complementary-dark'.

;;; Code:

(require 'complementary-light)
(require 'complementary-dark)

(defconst complementary-themes--root-directory
  (file-name-directory (or load-file-name buffer-file-name))
  "Installation root containing the complementary theme files.")

(add-to-list 'custom-theme-load-path
             (file-name-as-directory complementary-themes--root-directory))

(provide 'complementary-themes)
;;; complementary-themes.el ends here
