;;; complementary-themes-capture-screenshots.el --- Generate theme screenshots  -*- lexical-binding: t; -*-

;; Copyright (C) 2026
;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:

;; Build a repeatable three-window specimen in an isolated graphical Emacs and
;; export every supported primary accent, plus selected explicit pairs, as PNG.
;; Run this through the `screenshots' Make target rather than loading it from a
;; normal Emacs session.

;;; Code:

(require 'cl-lib)
(require 'subr-x)

(defconst complementary-themes-screenshot--root-directory
  (file-name-directory
   (directory-file-name
    (file-name-directory (or load-file-name buffer-file-name))))
  "Repository root used by the screenshot generator.")

(add-to-list 'load-path complementary-themes-screenshot--root-directory)
(add-to-list 'load-path
             (expand-file-name
              "lisp" complementary-themes-screenshot--root-directory))

(defconst complementary-themes-screenshot-color-names
  '(red orange yellow green teal cyan blue indigo purple magenta rose amber)
  "Primary accents included in the generated screenshot set.")

(defconst complementary-themes-screenshot-explicit-pairs
  '((yellow red) (blue green))
  "Additional primary/secondary pairs included in the screenshot set.")

(defconst complementary-themes-screenshot-jobs
  (append
   (cl-loop for variant in '(light dark)
            append
            (cl-loop for primary
                     in complementary-themes-screenshot-color-names
                     collect (list variant primary 'auto)))
   (cl-loop for variant in '(light dark)
            append
            (cl-loop for (primary secondary)
                     in complementary-themes-screenshot-explicit-pairs
                     collect (list variant primary secondary))))
  "Theme variants and accent pairs exported by the screenshot generator.")

(defun complementary-themes-screenshot-filename (job)
  "Return the PNG filename for screenshot JOB."
  (pcase-let ((`(,variant ,primary ,secondary) job))
    (if (eq secondary 'auto)
        (format "01_%s-%s.png" variant primary)
      (format "02_%s-%s-%s.png" variant primary secondary))))

(defun complementary-themes-screenshot--read-geometry (value)
  "Parse screenshot geometry VALUE.
Return the symbol `maximized' or a WIDTH/HEIGHT cons cell."
  (cond
   ((or (null value) (string-empty-p value)
        (string= value "maximized"))
    'maximized)
   ((string-match "\\`\\([1-9][0-9]*\\)x\\([1-9][0-9]*\\)\\'" value)
    (cons (string-to-number (match-string 1 value))
          (string-to-number (match-string 2 value))))
   (t
    (user-error
     "Invalid screenshot geometry %S; use maximized or WIDTHxHEIGHT" value))))

(defun complementary-themes-screenshot--configure-frame (frame geometry font)
  "Prepare FRAME for capture using GEOMETRY and FONT."
  (select-frame-set-input-focus frame)
  (set-frame-parameter frame 'title "Complementary Themes preview")
  (set-frame-parameter frame 'vertical-scroll-bars nil)
  (set-frame-parameter frame 'horizontal-scroll-bars nil)
  (menu-bar-mode -1)
  (tool-bar-mode -1)
  (when (fboundp 'scroll-bar-mode)
    (scroll-bar-mode -1))
  (when (fboundp 'tooltip-mode)
    (tooltip-mode -1))
  (blink-cursor-mode -1)
  (setq-default cursor-in-non-selected-windows nil)
  (when (and font (not (string-empty-p font)))
    (unless (find-font (font-spec :name font))
      (user-error "Screenshot font is unavailable: %s" font))
    (set-frame-font font t (list frame)))
  (pcase geometry
    ('maximized
     (set-frame-parameter frame 'fullscreen 'maximized))
    (`(,width . ,height)
     (set-frame-parameter frame 'fullscreen nil)
     (redisplay t)
     (sit-for 0.2)
     (set-frame-size frame width height t)))
  ;; Give the window manager time to apply the requested geometry before the
  ;; first export.  All images in one run subsequently use this same frame.
  (redisplay t)
  (sit-for 0.5))

(defun complementary-themes-screenshot--prepare-buffer (relative-file mode)
  "Visit RELATIVE-FILE, enable MODE, and prepare it for capture."
  (let ((buffer
         (find-file-noselect
          (expand-file-name
           relative-file complementary-themes-screenshot--root-directory))))
    (with-current-buffer buffer
      (funcall mode)
      (setq-local indicate-empty-lines nil)
      (setq-local show-trailing-whitespace nil)
      (goto-char (point-min))
      (font-lock-ensure))
    buffer))

(defun complementary-themes-screenshot--configure-tabs ()
  "Create stable active and inactive tab-bar samples."
  (require 'tab-bar)
  (setq tab-bar-close-button-show nil
        tab-bar-format '(tab-bar-format-history
                         tab-bar-format-tabs
                         tab-bar-separator
                         tab-bar-format-add-tab)
        tab-bar-tab-hints nil)
  (tab-bar-mode 1)
  (tab-bar-rename-tab "README.org")
  (tab-bar-new-tab)
  (tab-bar-rename-tab "Theme preview"))

(defun complementary-themes-screenshot--configure-windows ()
  "Build and return the windows used by the screenshot specimen."
  (require 'diff-mode)
  (require 'org)
  (let ((elisp-buffer
         (complementary-themes-screenshot--prepare-buffer
          "docs/complementary-themes-preview.el" #'emacs-lisp-mode))
        (diff-buffer
         (complementary-themes-screenshot--prepare-buffer
          "docs/complementary-themes-preview.diff" #'diff-mode))
        (org-buffer
         (complementary-themes-screenshot--prepare-buffer
          "docs/complementary-themes-preview.org" #'org-mode)))
    (delete-other-windows)
    (switch-to-buffer elisp-buffer)
    (let* ((elisp-window (selected-window))
           (org-window (split-window-right))
           (diff-window (split-window elisp-window nil 'below)))
      (set-window-buffer elisp-window elisp-buffer)
      (set-window-buffer diff-window diff-buffer)
      (set-window-buffer org-window org-buffer)
      (balance-windows)
      (dolist (window (list elisp-window diff-window org-window))
        (set-window-start window (point-min) t))
      (with-current-buffer elisp-buffer
        (setq-local truncate-lines t)
        (goto-char (point-min))
        (forward-line 17)
        (set-window-point elisp-window (point)))
      (with-current-buffer diff-buffer
        (setq-local truncate-lines t)
        (goto-char (point-min))
        (set-window-point diff-window (point)))
      (with-current-buffer org-buffer
        (setq-local truncate-lines nil)
        (goto-char (point-min))
        (set-window-point org-window (point)))
      (select-window elisp-window)
      (list elisp-window diff-window org-window))))

(defun complementary-themes-screenshot--set-theme (job)
  "Enable the theme and accent combination described by JOB."
  (pcase-let* ((`(,variant ,primary ,secondary) job)
               (theme (intern (format "complementary-%s" variant)))
               (primary-variable
                (intern (format "complementary-%s-primary-color" variant)))
               (secondary-variable
                (intern (format "complementary-%s-secondary-color" variant)))
               (refresh
                (intern (format "complementary-%s-refresh" variant))))
    (dolist (enabled-theme (copy-sequence custom-enabled-themes))
      (unless (eq enabled-theme theme)
        (disable-theme enabled-theme)))
    (set primary-variable primary)
    (set secondary-variable secondary)
    (if (custom-theme-p theme)
        (progn
          ;; Enabling first restores the theme's face properties after a
          ;; light/dark switch, allowing refresh to replace (rather than
          ;; duplicate) its stored settings.
          (unless (custom-theme-enabled-p theme)
            (enable-theme theme))
          (funcall refresh)
          ;; `custom-theme-set-faces' records replacement specs without its
          ;; NOW argument.  Re-enabling applies those specs to live faces.
          (enable-theme theme))
      (load-theme theme t))
    (unless (custom-theme-enabled-p theme)
      (enable-theme theme))))

(defun complementary-themes-screenshot--refresh-buffers (windows)
  "Refresh fontification and display for specimen WINDOWS."
  (dolist (window windows)
    (with-current-buffer (window-buffer window)
      (font-lock-flush)
      (font-lock-ensure)))
  (force-mode-line-update t)
  ;; Do not capture the progress message from the preceding image.
  (message nil)
  (redisplay t)
  (sit-for 0.05))

(defun complementary-themes-screenshot--write-png (frame file)
  "Atomically export FRAME to PNG FILE."
  (let ((temporary-file
         (make-temp-file
          (expand-file-name ".complementary-themes-screenshot-"
                            (file-name-directory file))
          nil ".png")))
    (unwind-protect
        (let ((coding-system-for-write 'no-conversion))
          (write-region (x-export-frames frame 'png)
                        nil temporary-file nil 'silent)
          (rename-file temporary-file file t))
      (when (file-exists-p temporary-file)
        (delete-file temporary-file)))))

;;;###autoload
(defun complementary-themes-capture-screenshots (&optional directory)
  "Generate all theme screenshots below DIRECTORY.

When DIRECTORY is nil, use the environment variable
COMPLEMENTARY_THEMES_SCREENSHOT_DIR or the repository's Screenshots
directory.  Frame geometry comes from
COMPLEMENTARY_THEMES_SCREENSHOT_GEOMETRY and accepts `maximized' or
WIDTHxHEIGHT.  COMPLEMENTARY_THEMES_SCREENSHOT_FONT optionally selects the
frame font."
  (interactive)
  (unless (display-graphic-p)
    (user-error "Screenshot generation requires a graphical Emacs frame"))
  (unless (fboundp 'x-export-frames)
    (user-error "This Emacs was built without x-export-frames"))
  (let* ((output-directory
          (file-name-as-directory
           (expand-file-name
            (or directory
                (getenv "COMPLEMENTARY_THEMES_SCREENSHOT_DIR")
                "Screenshots")
            complementary-themes-screenshot--root-directory)))
         (geometry
          (complementary-themes-screenshot--read-geometry
           (getenv "COMPLEMENTARY_THEMES_SCREENSHOT_GEOMETRY")))
         (font (getenv "COMPLEMENTARY_THEMES_SCREENSHOT_FONT"))
         (frame (selected-frame))
         windows)
    (make-directory output-directory t)
    (add-to-list 'custom-theme-load-path
                 complementary-themes-screenshot--root-directory)
    (complementary-themes-screenshot--configure-frame frame geometry font)
    (complementary-themes-screenshot--configure-tabs)
    (setq windows (complementary-themes-screenshot--configure-windows))
    (dolist (job complementary-themes-screenshot-jobs)
      (complementary-themes-screenshot--set-theme job)
      (complementary-themes-screenshot--refresh-buffers windows)
      (let ((file
             (expand-file-name
              (complementary-themes-screenshot-filename job)
              output-directory)))
        (complementary-themes-screenshot--write-png frame file)
        (message "Captured %s (%dx%d)"
                 (file-name-nondirectory file)
                 (frame-pixel-width frame)
                 (frame-pixel-height frame))))
    (message "Generated %d screenshots in %s"
             (length complementary-themes-screenshot-jobs)
             output-directory)
    output-directory))

(defun complementary-themes-capture-screenshots-cli ()
  "Generate screenshots and terminate Emacs with an appropriate status."
  (condition-case error-data
      (progn
        (complementary-themes-capture-screenshots)
        (kill-emacs 0))
    (error
     (message "Screenshot generation failed: %s"
              (error-message-string error-data))
     (kill-emacs 1))))

(provide 'complementary-themes-capture-screenshots)
;;; complementary-themes-capture-screenshots.el ends here
