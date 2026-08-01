;;; complementary-light-preview.el --- Visual theme specimen  -*- lexical-binding: t; -*-

;; Copyright (C) 2026
;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:

;; A read-only specimen for palette, UI, semantic, syntax and overlap review.
;; `n' and `p' change only this buffer's palette swatches; they do not write
;; Customize values or alter the enabled theme.

;;; Code:

(require 'cl-lib)
(require 'complementary-light-palette)

(defvar complementary-light--resolved-primary)
(defvar complementary-light--resolved-secondary)
(defvar complementary-light-primary-color)
(defvar complementary-light-secondary-color)

(defvar-local complementary-light-preview-primary nil)
(defvar-local complementary-light-preview-secondary nil)

(defvar complementary-light-preview-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "n") #'complementary-light-preview-next-preset)
    (define-key map (kbd "p") #'complementary-light-preview-previous-preset)
    (define-key map (kbd "g") #'complementary-light-preview-redraw)
    (define-key map (kbd "q") #'quit-window)
    map)
  "Keymap for `complementary-light-preview-mode'.")

(define-derived-mode complementary-light-preview-mode special-mode
  "Complementary-Light-Preview"
  "Major mode for the complementary-light visual specimen.")

(defun complementary-light-preview--insert-face (label face)
  "Insert LABEL rendered with FACE."
  (insert (propertize (format "%-28s  The quick brown fox 0123456789\n" label)
                      'face face)))

(defun complementary-light-preview--insert-anonymous (label attributes)
  "Insert LABEL with anonymous face ATTRIBUTES."
  (insert (propertize (format "%-28s  The quick brown fox 0123456789\n" label)
                      'face attributes)))

(defun complementary-light-preview--swatch (role name token)
  "Insert a swatch for ROLE palette NAME and TOKEN."
  (let* ((keyword (intern (concat ":" (symbol-name token))))
         (color (complementary-light--accent-token name keyword))
         (background-p (memq token '(strong medium subtle)))
         (foreground (if background-p
                         (complementary-light--accent-token
                          name (intern (format ":on-%s" token)))
                       color))
         (background (if background-p color
                       (complementary-light-token
                        'background name
                        (complementary-light-paired-accent name)))))
    (insert (propertize
             (format "%-10s %-20s %-10s  %s\n" role token color "Aa 0123")
             'face (list :foreground foreground :background background)))))

(defun complementary-light-preview--code (title lines)
  "Insert syntax sample TITLE whose LINES are (TEXT FACE) pairs."
  (insert (propertize (concat title "\n") 'face 'outline-2))
  (dolist (line lines)
    (insert (propertize (car line) 'face (cadr line)) "\n"))
  (insert "\n"))

(defun complementary-light-preview-redraw ()
  "Redraw the current preview buffer."
  (interactive)
  (let ((inhibit-read-only t)
        (primary (or complementary-light-preview-primary
                     complementary-light--resolved-primary
                     complementary-light-primary-color))
        (secondary (or complementary-light-preview-secondary
                       complementary-light--resolved-secondary
                       (complementary-light-resolve-secondary
                        complementary-light-primary-color
                        complementary-light-secondary-color t))))
    (erase-buffer)
    (insert (propertize "complementary-light preview\n" 'face 'outline-1))
    (insert (format "Primary: %s    Secondary: %s (%s)    colors: %s\n"
                    primary secondary
                    (if (eq complementary-light-secondary-color 'auto)
                        "automatic paired accent" "explicit")
                    (display-color-cells)))
    (insert "Keys: n/p local palette preset, g redraw, q quit\n\n")

    (insert (propertize "Text and default non-color attributes\n" 'face 'outline-2))
    (dolist (sample '(("normal" default) ("secondary text" shadow)
                      ("muted text" font-lock-comment-face)
                      ("faint text" line-number) ("bold" bold)
                      ("italic" italic) ("underlined" underline)
                      ("link" link) ("visited link" link-visited)
                      ("error / default attributes" error)
                      ("warning / default attributes" warning)
                      ("success / default attributes" success)
                      ("information" help-key-binding)))
      (complementary-light-preview--insert-face (car sample) (cadr sample)))
    (complementary-light-preview--insert-anonymous
     "wave underline" (list :underline (list :style 'wave :color
                                               (complementary-light-token
                                                'primary-border primary secondary))))
    (complementary-light-preview--insert-anonymous
     "box" (list :box (complementary-light-token
                        'secondary-border primary secondary)))
    (complementary-light-preview--insert-anonymous
     "strike-through" '(:strike-through t))

    (insert "\n" (propertize "Selections and UI faces\n" 'face 'outline-2))
    (dolist (sample '(("region" region) ("secondary-selection" secondary-selection)
                      ("highlight" highlight) ("isearch" isearch)
                      ("lazy-highlight" lazy-highlight) ("match" match)
                      ("hl-line" hl-line) ("line-number" line-number)
                      ("current line number" line-number-current-line)
                      ("mode-line" mode-line) ("inactive mode-line" mode-line-inactive)
                      ("header-line" header-line) ("tab-bar" tab-bar)
                      ("tab-line" tab-line) ("tooltip" tooltip)
                      ("completion selection" completions-highlight)
                      ("diff added" diff-added) ("diff removed" diff-removed)
                      ("diff changed" diff-changed) ("ediff current" ediff-current-diff-A)))
      (complementary-light-preview--insert-face (car sample) (cadr sample)))

    (insert "\n" (propertize "Font Lock inventory\n" 'face 'outline-2))
    (dolist (face '(font-lock-builtin-face font-lock-comment-face
                    font-lock-constant-face font-lock-doc-face
                    font-lock-function-call-face font-lock-function-name-face
                    font-lock-keyword-face font-lock-number-face
                    font-lock-preprocessor-face font-lock-property-name-face
                    font-lock-string-face font-lock-type-face
                    font-lock-variable-name-face font-lock-warning-face))
      (complementary-light-preview--insert-face (symbol-name face) face))

    (insert "\n")
    (complementary-light-preview--code
     "Emacs Lisp"
     '(("(defun " font-lock-keyword-face)
       ("greet" font-lock-function-name-face)
       (" (name)" default)
       ("  \"Return a greeting.\"" font-lock-doc-face)
       ("  (message \"Hello, %s\" name))" font-lock-string-face)))
    ;; Keep compact multi-language specimens fontified by the same semantic
    ;; classes; their purpose is hue allocation, not parser correctness.
    (dolist (sample '(("HTML" "<article class=\"note\">Hello</article>")
                      ("CSS" ".note { color: currentColor; }")
                      ("JavaScript" "const greet = (name) => `Hello ${name}`;")
                      ("JSON" "{\"enabled\": true, \"count\": 2}")
                      ("Shell" "for file in *; do printf '%s\\n' \"$file\"; done")
                      ("Org / Outline" "* TODO Review paired accent contrast")))
      (complementary-light-preview--code
       (car sample) (list (list (cadr sample) 'font-lock-string-face))))

    (insert (propertize "Accent tokens\n" 'face 'outline-2))
    (dolist (role `((primary ,primary) (secondary ,secondary)))
      (dolist (token '(text strong on-strong medium on-medium subtle on-subtle
                       border focus distant-foreground))
        (complementary-light-preview--swatch (car role) (cadr role) token)))

    (insert "\n" (propertize "Declared contrast pairs\n" 'face 'outline-2))
    (dolist (pair complementary-light-contrast-pairs)
      (let* ((fg (complementary-light-token (nth 0 pair) primary secondary))
             (bg (complementary-light-token (nth 1 pair) primary secondary))
             (ratio (complementary-light-contrast-ratio fg bg)))
        (insert (format "%-34s %6.2f : 1  required %.1f\n"
                        (format "%s / %s" (nth 0 pair) (nth 1 pair))
                        ratio (nth 2 pair)))))
    (goto-char (point-min))))

(defun complementary-light-preview--cycle (step)
  "Cycle local preview primary by STEP without changing user settings."
  (let* ((current (or complementary-light-preview-primary
                      complementary-light-primary-color))
         (position (or (cl-position current complementary-light-color-names) 0))
         (next (nth (mod (+ position step)
                         (length complementary-light-color-names))
                    complementary-light-color-names)))
    (setq complementary-light-preview-primary next
          complementary-light-preview-secondary
          (complementary-light-paired-accent next))
    (complementary-light-preview-redraw)))

(defun complementary-light-preview-next-preset ()
  "Show the next paired accent in this preview only."
  (interactive)
  (complementary-light-preview--cycle 1))

(defun complementary-light-preview-previous-preset ()
  "Show the previous paired accent in this preview only."
  (interactive)
  (complementary-light-preview--cycle -1))

(defun complementary-light-preview-buffer ()
  "Create and display the complementary-light preview buffer."
  (let ((buffer (get-buffer-create "*complementary-light preview*")))
    (with-current-buffer buffer
      (complementary-light-preview-mode)
      (setq complementary-light-preview-primary
            (or complementary-light--resolved-primary
                complementary-light-primary-color)
            complementary-light-preview-secondary
            (or complementary-light--resolved-secondary
                (complementary-light-resolve-secondary
                 complementary-light-primary-color
                 complementary-light-secondary-color t)))
      (complementary-light-preview-redraw))
    (pop-to-buffer buffer)))

(provide 'complementary-light-preview)
;;; complementary-light-preview.el ends here
