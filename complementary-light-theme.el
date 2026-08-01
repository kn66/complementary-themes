;;; complementary-light-theme.el --- Minimal paired-accent light theme  -*- lexical-binding: t; -*-

;; Copyright (C) 2026
;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:

;; A neutral WCAG AA-calibrated light theme with two registered accents.

;;; Code:

;;;###theme-autoload
(deftheme complementary-light
  "A minimal WCAG AA-calibrated light theme using two registered accents.")

(declare-function complementary-light--register-theme "complementary-light")

(let* ((theme-file (or load-file-name buffer-file-name))
       (root (file-name-directory theme-file)))
  (load (expand-file-name "complementary-light.el" root) nil nil t))

(complementary-light--register-theme t)

;;;###autoload
(when load-file-name
  (add-to-list 'custom-theme-load-path
               (file-name-as-directory
                (file-name-directory load-file-name))))

(provide-theme 'complementary-light)
;;; complementary-light-theme.el ends here
