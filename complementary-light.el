;;; complementary-light.el --- User controls for complementary-light  -*- lexical-binding: t; -*-

;; Copyright (C) 2026
;; SPDX-License-Identifier: GPL-3.0-or-later
;; Version: 0.2.0
;; Package-Requires: ((emacs "29.1"))
;; Keywords: faces, themes

;;; Commentary:

;; User-facing customization and safe, idempotent theme refresh commands.

;;; Code:

(require 'custom)
(require 'cl-lib)

;;;###autoload
(let ((package-root
       (file-name-directory (or load-file-name buffer-file-name))))
  (add-to-list 'load-path (expand-file-name "lisp" package-root)))

(defvar complementary-light-color-names)
(defvar complementary-light-neutral-palette)
(defvar complementary-light-palettes)

(declare-function complementary-light-preview-buffer
                  "complementary-light-preview")
(declare-function complementary-light-build-face-specs
                  "complementary-light-faces")
(declare-function complementary-light-build-package-face-specs
                  "complementary-light-packages")
(declare-function complementary-light-package-note-registration
                  "complementary-light-packages")
(declare-function complementary-light-resolve-secondary
                  "complementary-light-palette")

(defconst complementary-light--root-directory
  (file-name-directory (or load-file-name buffer-file-name))
  "Installation root of complementary-light.")

(dolist (module '("complementary-light-palette.el"
                  "complementary-light-faces.el"
                  "complementary-light-packages.el"))
  (load (expand-file-name (concat "lisp/" module)
                          complementary-light--root-directory)
        nil nil t))

(defgroup complementary-light nil
  "WCAG AA-calibrated light theme with two registered accents."
  :group 'faces)

(defcustom complementary-light-primary-color 'yellow
  "Primary accent color used by `complementary-light'."
  :type '(choice
          (const red) (const orange) (const yellow) (const green)
          (const teal) (const cyan) (const blue) (const indigo)
          (const purple) (const magenta) (const rose) (const amber))
  :group 'complementary-light)

(defcustom complementary-light-secondary-color 'auto
  "Secondary accent color used by `complementary-light'.

When this value is `auto', use the registered paired accent for
`complementary-light-primary-color'."
  :type '(choice
          (const auto)
          (const red) (const orange) (const yellow) (const green)
          (const teal) (const cyan) (const blue) (const indigo)
          (const purple) (const magenta) (const rose) (const amber))
  :group 'complementary-light)

(defvar complementary-light--resolved-primary nil
  "Primary color used by the most recent theme registration.")

(defvar complementary-light--resolved-secondary nil
  "Secondary color used by the most recent theme registration.")

(defun complementary-light--remove-theme-face-setting-for-theme (theme face)
  "Remove THEME's obsolete setting for FACE and recalculate it."
  (put theme 'theme-settings
       (cl-delete-if
        (lambda (setting)
          (and (eq (car setting) 'theme-face)
               (eq (nth 1 setting) face)))
        (get theme 'theme-settings)))
  (put face 'theme-face
       (assq-delete-all theme (get face 'theme-face)))
  (when (facep face)
    (custom-theme-recalc-face face)))

(defun complementary-light--remove-theme-face-setting (face)
  "Remove complementary-light's obsolete setting for FACE and recalculate it."
  (complementary-light--remove-theme-face-setting-for-theme
   'complementary-light face))

(defun complementary-light--valid-primary (&optional startup)
  "Return the configured primary, handling invalid values for STARTUP."
  (if (memq complementary-light-primary-color
            complementary-light-color-names)
      complementary-light-primary-color
    (if startup
        (progn
          (display-warning
           'complementary-light
           (format "Unknown primary %S; using yellow for this load"
                   complementary-light-primary-color))
          'yellow)
      (user-error "Unknown complementary-light color: %S"
                  complementary-light-primary-color))))

(defun complementary-light--register-theme (&optional startup)
  "Register current palette specs for the theme.
STARTUP enables warning-and-fallback behavior for invalid init values."
  (let* ((primary (complementary-light--valid-primary startup))
         (secondary (complementary-light-resolve-secondary
                     primary complementary-light-secondary-color startup))
         (specs (append
                 (complementary-light-build-face-specs primary secondary)
                 (complementary-light-build-package-face-specs
                  primary secondary)))
         (new-faces (mapcar #'car specs))
         (old-faces
          (cl-loop for setting in (get 'complementary-light 'theme-settings)
                   when (eq (car setting) 'theme-face)
                   collect (nth 1 setting)))
         (stale-faces (cl-set-difference old-faces new-faces)))
    (setq complementary-light--resolved-primary primary
          complementary-light--resolved-secondary secondary)
    (mapc #'complementary-light--remove-theme-face-setting stale-faces)
    ;; `custom-push-theme' replaces an existing setting for a given face/theme,
    ;; so this neither grows duplicates nor touches the special user theme.
    (apply #'custom-theme-set-faces 'complementary-light specs)
    (complementary-light-package-note-registration
     'complementary-light primary secondary
     complementary-light-neutral-palette complementary-light-palettes)))

;;;###autoload
(defun complementary-light-refresh ()
  "Rebuild complementary-light from the current registered color names.

Other enabled themes are neither disabled nor reordered.  If this theme is
inactive, only its stored theme settings are rebuilt."
  (interactive)
  (let ((before (copy-sequence custom-enabled-themes))
        (user-settings (copy-tree (get 'user 'theme-settings))))
    (complementary-light--register-theme nil)
    (unless (equal before custom-enabled-themes)
      (error "Theme refresh unexpectedly changed enabled-theme order"))
    (unless (equal user-settings (get 'user 'theme-settings))
      (error "Theme refresh unexpectedly changed the user theme")))
  (when (called-interactively-p 'interactive)
    (message "complementary-light refreshed: %s + %s"
             complementary-light--resolved-primary
             complementary-light--resolved-secondary)))

(defun complementary-light--read-color (prompt &optional auto)
  "Read a registered color name with PROMPT.
When AUTO is non-nil, include the symbol `auto'."
  (let* ((choices (append (when auto '(auto))
                          complementary-light-color-names))
         (answer (completing-read prompt (mapcar #'symbol-name choices)
                                  nil t nil nil
                                  (symbol-name (if auto
                                                   complementary-light-secondary-color
                                                 complementary-light-primary-color)))))
    (intern answer)))

;;;###autoload
(defun complementary-light-set-primary-color (color)
  "Set primary accent to registered COLOR and refresh if enabled."
  (interactive (list (complementary-light--read-color "Primary accent: ")))
  (unless (memq color complementary-light-color-names)
    (user-error "Unknown complementary-light color: %S" color))
  (setq complementary-light-primary-color color)
  (when (custom-theme-enabled-p 'complementary-light)
    (complementary-light-refresh))
  color)

;;;###autoload
(defun complementary-light-set-secondary-color (color)
  "Set secondary accent to registered COLOR or `auto', refreshing if enabled."
  (interactive (list (complementary-light--read-color "Secondary accent: " t)))
  (unless (memq color (cons 'auto complementary-light-color-names))
    (user-error "Unknown complementary-light color: %S" color))
  (setq complementary-light-secondary-color color)
  (when (custom-theme-enabled-p 'complementary-light)
    (complementary-light-refresh))
  color)

;;;###autoload
(defun complementary-light-preview ()
  "Open the complementary-light preview buffer."
  (interactive)
  (load (expand-file-name "lisp/complementary-light-preview.el"
                          complementary-light--root-directory)
        nil nil t)
  (complementary-light-preview-buffer))

(provide 'complementary-light)
;;; complementary-light.el ends here
