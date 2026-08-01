;;; complementary-dark-theme.el --- Minimal paired-accent dark theme  -*- lexical-binding: t; -*-

;; Copyright (C) 2026
;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:

;; A neutral WCAG AA-calibrated dark theme with two registered accents.

;;; Code:

;;;###theme-autoload
(deftheme complementary-dark
  "A minimal WCAG AA-calibrated dark theme using two registered accents.")

(declare-function complementary-dark--register-theme "complementary-dark")

(let* ((theme-file (or load-file-name buffer-file-name))
       (root (file-name-directory theme-file)))
  (load (expand-file-name "complementary-dark.el" root) nil nil t))

(complementary-dark--register-theme t)

;;;###autoload
(when load-file-name
  (add-to-list 'custom-theme-load-path
               (file-name-as-directory
                (file-name-directory load-file-name))))

(provide-theme 'complementary-dark)
;;; complementary-dark-theme.el ends here
