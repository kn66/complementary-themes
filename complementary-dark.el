;;; complementary-dark.el --- User controls for complementary-dark  -*- lexical-binding: t; -*-

;; Copyright (C) 2026
;; SPDX-License-Identifier: GPL-3.0-or-later
;; Version: 0.2.0
;; Package-Requires: ((emacs "30.2"))
;; Keywords: faces, themes

;;; Commentary:

;; User-facing customization and refresh commands for the dark counterpart to
;; complementary-light.  Face policy is shared; only the semantic palettes and
;; independent user settings differ.

;;; Code:

(require 'complementary-light)
(require 'complementary-dark-palette)

(declare-function complementary-light--remove-theme-face-setting-for-theme
                  "complementary-light")

(defgroup complementary-dark nil
  "WCAG AA-calibrated dark theme with two registered accents."
  :group 'faces)

(defcustom complementary-dark-primary-color 'yellow
  "Primary accent color used by `complementary-dark'."
  :type '(choice
          (const red) (const orange) (const yellow) (const green)
          (const teal) (const cyan) (const blue) (const indigo)
          (const purple) (const magenta) (const rose) (const amber))
  :group 'complementary-dark)

(defcustom complementary-dark-secondary-color 'auto
  "Secondary accent color used by `complementary-dark'.

When this value is `auto', use the registered paired accent for
`complementary-dark-primary-color'."
  :type '(choice
          (const auto)
          (const red) (const orange) (const yellow) (const green)
          (const teal) (const cyan) (const blue) (const indigo)
          (const purple) (const magenta) (const rose) (const amber))
  :group 'complementary-dark)

(defvar complementary-dark--resolved-primary nil
  "Primary color used by the most recent dark-theme registration.")

(defvar complementary-dark--resolved-secondary nil
  "Secondary color used by the most recent dark-theme registration.")

(defun complementary-dark--valid-primary (&optional startup)
  "Return the configured dark primary, handling invalid values for STARTUP."
  (if (memq complementary-dark-primary-color
            complementary-light-color-names)
      complementary-dark-primary-color
    (if startup
        (progn
          (display-warning
           'complementary-dark
           (format "Unknown primary %S; using yellow for this load"
                   complementary-dark-primary-color))
          'yellow)
      (user-error "Unknown complementary-dark color: %S"
                  complementary-dark-primary-color))))

(defun complementary-dark--valid-secondary (primary &optional startup)
  "Return the configured dark secondary for PRIMARY.
Handle invalid values with warning-and-fallback behavior when STARTUP is
non-nil."
  (cond
   ((eq complementary-dark-secondary-color 'auto)
    (complementary-light-paired-accent primary))
   ((and (memq complementary-dark-secondary-color
               complementary-light-color-names)
         (not (eq complementary-dark-secondary-color primary)))
    complementary-dark-secondary-color)
   ((eq complementary-dark-secondary-color primary)
    (if startup
        (progn
          (display-warning
           'complementary-dark
           (format "Secondary %S matches primary; using paired accent"
                   complementary-dark-secondary-color))
          (complementary-light-paired-accent primary))
      (user-error "Primary and secondary accents must be distinct: %S"
                  primary)))
   (startup
    (display-warning
     'complementary-dark
     (format "Unknown secondary %S; using paired accent"
             complementary-dark-secondary-color))
    (complementary-light-paired-accent primary))
   (t
    (user-error "Unknown complementary-dark color: %S"
                complementary-dark-secondary-color))))

(defun complementary-dark--register-theme (&optional startup)
  "Register current dark palette specs.
STARTUP enables warning-and-fallback behavior for invalid init values."
  (let* ((primary (complementary-dark--valid-primary startup))
         (secondary (complementary-dark--valid-secondary primary startup))
         (specs
          (complementary-dark--with-palette
            (append
             (complementary-light-build-face-specs primary secondary)
             (complementary-light-build-package-face-specs
              primary secondary))))
         (new-faces (mapcar #'car specs))
         (old-faces
          (cl-loop for setting in (get 'complementary-dark 'theme-settings)
                   when (eq (car setting) 'theme-face)
                   collect (nth 1 setting)))
         (stale-faces (cl-set-difference old-faces new-faces)))
    (setq complementary-dark--resolved-primary primary
          complementary-dark--resolved-secondary secondary)
    (mapc (lambda (face)
            (complementary-light--remove-theme-face-setting-for-theme
             'complementary-dark face))
          stale-faces)
    (apply #'custom-theme-set-faces 'complementary-dark specs)
    (complementary-light-package-note-registration
     'complementary-dark primary secondary
     complementary-dark-neutral-palette complementary-dark-palettes)))

;;;###autoload
(defun complementary-dark-refresh ()
  "Rebuild complementary-dark from its current registered color names.

Other enabled themes are neither disabled nor reordered.  If this theme is
inactive, only its stored theme settings are rebuilt."
  (interactive)
  (let ((before (copy-sequence custom-enabled-themes))
        (user-settings (copy-tree (get 'user 'theme-settings))))
    (complementary-dark--register-theme nil)
    (unless (equal before custom-enabled-themes)
      (error "Dark theme refresh unexpectedly changed enabled-theme order"))
    (unless (equal user-settings (get 'user 'theme-settings))
      (error "Dark theme refresh unexpectedly changed the user theme")))
  (when (called-interactively-p 'interactive)
    (message "complementary-dark refreshed: %s + %s"
             complementary-dark--resolved-primary
             complementary-dark--resolved-secondary)))

(defun complementary-dark--read-color (prompt &optional auto)
  "Read a registered dark color name with PROMPT.
When AUTO is non-nil, include the symbol `auto'."
  (let* ((choices (append (when auto '(auto))
                          complementary-light-color-names))
         (current (if auto complementary-dark-secondary-color
                    complementary-dark-primary-color))
         (answer (completing-read prompt (mapcar #'symbol-name choices)
                                  nil t nil nil (symbol-name current))))
    (intern answer)))

;;;###autoload
(defun complementary-dark-set-primary-color (color)
  "Set the dark primary accent to registered COLOR and refresh if enabled."
  (interactive (list (complementary-dark--read-color "Primary accent: ")))
  (unless (memq color complementary-light-color-names)
    (user-error "Unknown complementary-dark color: %S" color))
  (when (eq color complementary-dark-secondary-color)
    (user-error "Primary and secondary accents must be distinct: %S" color))
  (setq complementary-dark-primary-color color)
  (when (custom-theme-enabled-p 'complementary-dark)
    (complementary-dark-refresh))
  color)

;;;###autoload
(defun complementary-dark-set-secondary-color (color)
  "Set the dark secondary accent to COLOR or `auto', refreshing if enabled."
  (interactive (list (complementary-dark--read-color "Secondary accent: " t)))
  (unless (memq color (cons 'auto complementary-light-color-names))
    (user-error "Unknown complementary-dark color: %S" color))
  (when (eq color complementary-dark-primary-color)
    (user-error "Primary and secondary accents must be distinct: %S" color))
  (setq complementary-dark-secondary-color color)
  (when (custom-theme-enabled-p 'complementary-dark)
    (complementary-dark-refresh))
  color)

;;;###autoload
(defun complementary-dark-use-color-vision-preset ()
  "Select the audited color-vision preset and refresh if enabled."
  (interactive)
  (setq complementary-dark-primary-color
        (car complementary-light-color-vision-preset)
        complementary-dark-secondary-color
        (cdr complementary-light-color-vision-preset))
  (when (custom-theme-enabled-p 'complementary-dark)
    (complementary-dark-refresh))
  (when (called-interactively-p 'interactive)
    (message "complementary-dark CVD preset: %s + %s"
             complementary-dark-primary-color
             complementary-dark-secondary-color))
  complementary-light-color-vision-preset)

(provide 'complementary-dark)
;;; complementary-dark.el ends here
