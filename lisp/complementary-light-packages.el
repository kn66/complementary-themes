;;; complementary-light-packages.el --- External package face support  -*- lexical-binding: t; -*-

;; Copyright (C) 2026
;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:

;; Color-only rules for packages installed by the companion init.org.  Faces
;; which already inherit a themed Emacs face need no entry here: retaining that
;; inheritance also retains package-owned weight, slant, box, and other state.
;; This module only replaces independent package colors with palette tokens.

;;; Code:

(require 'cl-lib)
(require 'complementary-light-palette)

(defvar complementary-light--resolved-primary)
(defvar complementary-light--resolved-secondary)
(declare-function complementary-light--default-face-spec
                  "complementary-light-faces")
(declare-function complementary-light--display-clauses
                  "complementary-light-faces")

(defconst complementary-light-supported-packages
  '(avy bbdb cognitive-complexity consult corfu ddskk denote diff-hl eglot
    embark emmet-mode magit magit-section marginalia relint tempel transient
    treesit-fold vundo wgrep which-key)
  "External packages whose visible faces follow complementary-light.
Packages without explicit rules here use the already-themed faces they inherit.")

(defconst complementary-light-package-face-rules
  '(
    ;; Avy.
    (avy-background-face :package avy :foreground foreground-muted)
    (avy-lead-face :package avy :foreground primary-on-strong :background primary-strong)
    (avy-lead-face-0 :package avy :foreground secondary-on-strong :background secondary-strong)
    (avy-lead-face-1 :package avy :foreground primary-on-medium :background primary-medium)
    (avy-lead-face-2 :package avy :foreground secondary-on-medium :background secondary-medium)

    ;; Cognitive complexity indicators.
    (cognitive-complexity-default :package cognitive-complexity :foreground foreground-muted)
    (cognitive-complexity-average :package cognitive-complexity :foreground secondary-text)
    (cognitive-complexity-high :package cognitive-complexity :foreground secondary-text)
    (cognitive-complexity-extreme :package cognitive-complexity :foreground primary-text)

    ;; Corfu and its bundled extensions.
    (corfu-default :package corfu :foreground foreground :background surface-raised)
    (corfu-current :package corfu :foreground primary-on-medium :background primary-medium)
    (corfu-bar :package corfu :background foreground-muted)
    (corfu-border :package corfu :background border)
    (corfu-echo :package corfu :foreground foreground-secondary :background surface-raised)
    (corfu-indexed :package corfu :foreground foreground-secondary :background surface-sunken)
    (corfu-quick1 :package corfu :foreground primary-on-strong :background primary-strong)
    (corfu-quick2 :package corfu :foreground secondary-on-strong :background secondary-strong)

    ;; Denote otherwise follows Font Lock and link faces through inheritance.
    (denote-faces-delimiter :package denote :foreground foreground-faint)

    ;; diff-hl.  The dired and margin variants inherit these three faces.
    (diff-hl-insert :package diff-hl :foreground secondary-text :background secondary-subtle)
    (diff-hl-delete :package diff-hl :foreground primary-text :background primary-subtle)
    (diff-hl-change :package diff-hl :foreground primary-text :background secondary-subtle)

    ;; Magit references, state, and navigation.
    (magit-bisect-good :package magit :foreground secondary-text)
    (magit-bisect-skip :package magit :foreground secondary-text)
    (magit-bisect-bad :package magit :foreground primary-text)
    (magit-blame-highlight :package magit :foreground foreground :background surface-sunken)
    (magit-branch-local :package magit :foreground primary-text)
    (magit-branch-remote :package magit :foreground secondary-text)
    (magit-cherry-unmatched :package magit :foreground primary-text)
    (magit-cherry-equivalent :package magit :foreground secondary-text)
    (magit-dimmed :package magit :foreground foreground-muted)
    (magit-hash :package magit :foreground foreground-faint)
    (magit-log-author :package magit :foreground secondary-text)
    (magit-log-date :package magit :foreground foreground-muted)
    (magit-log-graph :package magit :foreground foreground-muted)
    (magit-process-ok :package magit :foreground secondary-text)
    (magit-process-ng :package magit :foreground primary-text)
    (magit-refname :package magit :foreground foreground-secondary)
    (magit-section-heading :package magit-section :foreground primary-text)
    (magit-section-heading-selection :package magit-section :foreground primary-text)
    (magit-section-highlight :package magit-section :background surface-raised)
    (magit-tag :package magit :foreground secondary-text)

    ;; Magit diffs.  Primary denotes removal/failure and secondary addition.
    (magit-diff-context :package magit :foreground foreground-muted)
    (magit-diff-context-highlight :package magit :foreground foreground-muted :background surface-raised)
    (magit-diff-file-heading-selection :package magit :foreground primary-text)
    (magit-diff-hunk-heading :package magit :foreground foreground-secondary :background surface-sunken)
    (magit-diff-hunk-heading-highlight :package magit :foreground foreground :background surface-raised)
    (magit-diff-hunk-heading-selection :package magit :foreground primary-text :background surface-raised)
    (magit-diff-lines-heading :package magit :foreground primary-on-medium :background primary-medium)
    (magit-diff-added :package magit :foreground secondary-text :background secondary-subtle)
    (magit-diff-added-highlight :package magit :foreground secondary-text :background secondary-subtle)
    (magit-diff-added-indicator :package magit :foreground secondary-text)
    (magit-diff-removed :package magit :foreground primary-text :background primary-subtle)
    (magit-diff-removed-highlight :package magit :foreground primary-text :background primary-subtle)
    (magit-diff-removed-indicator :package magit :foreground primary-text)
    (magit-diff-base :package magit :foreground primary-text :background secondary-subtle)
    (magit-diff-base-highlight :package magit :foreground primary-text :background secondary-subtle)
    (magit-diff-base-indicator :package magit :foreground primary-text)
    (magit-diff-base-heading :package magit :foreground secondary-on-medium :background secondary-medium)
    (magit-diff-our-heading :package magit :foreground primary-on-strong :background primary-strong)
    (magit-diff-their-heading :package magit :foreground secondary-on-strong :background secondary-strong)
    (magit-diffstat-added :package magit :foreground secondary-text)
    (magit-diffstat-removed :package magit :foreground primary-text)

    ;; Magit sequencing, signatures, and reflog.
    (magit-sequence-drop :package magit :foreground primary-text)
    (magit-sequence-head :package magit :foreground primary-text)
    (magit-sequence-part :package magit :foreground secondary-text)
    (magit-sequence-stop :package magit :foreground secondary-text)
    (magit-signature-good :package magit :foreground secondary-text)
    (magit-signature-bad :package magit :foreground primary-text)
    (magit-signature-untrusted :package magit :foreground secondary-text)
    (magit-signature-expired :package magit :foreground secondary-text)
    (magit-signature-revoked :package magit :foreground primary-text)
    (magit-signature-error :package magit :foreground primary-text)
    (magit-reflog-commit :package magit :foreground secondary-text)
    (magit-reflog-amend :package magit :foreground primary-text)
    (magit-reflog-merge :package magit :foreground secondary-text)
    (magit-reflog-checkout :package magit :foreground primary-text)
    (magit-reflog-reset :package magit :foreground primary-text)
    (magit-reflog-rebase :package magit :foreground primary-text)
    (magit-reflog-cherry-pick :package magit :foreground secondary-text)
    (magit-reflog-remote :package magit :foreground secondary-text)
    (magit-reflog-other :package magit :foreground foreground-secondary)

    ;; DDSKK conversion, candidate, and tutorial UI.
    (skk-henkan-face-default :package ddskk :foreground secondary-on-medium :background secondary-medium)
    (skk-prefix-hiragana-face :package ddskk :foreground primary-text)
    (skk-prefix-katakana-face :package ddskk :foreground secondary-text)
    (skk-prefix-jisx0201-face :package ddskk :foreground primary-text)
    (skk-dcomp-face :package ddskk :foreground foreground-muted)
    (skk-dcomp-multiple-face :package ddskk :foreground foreground-secondary :background secondary-subtle)
    (skk-dcomp-multiple-trailing-face :package ddskk :foreground foreground :background secondary-subtle)
    (skk-dcomp-multiple-selected-face :package ddskk :foreground secondary-on-strong :background secondary-strong)
    (skk-display-code-prompt-face :package ddskk :foreground primary-text)
    (skk-display-code-char-face :package ddskk :foreground primary-on-medium :background primary-medium)
    (skk-list-chars-table-header-face :package ddskk :foreground primary-text)
    (skk-show-mode-inline-face :package ddskk :foreground foreground :background surface-raised)
    (skk-verbose-kbd-face :package ddskk :foreground primary-text)
    (skk-tut-section-face :package ddskk :foreground primary-on-strong :background primary-strong)
    (skk-tut-do-it-face :package ddskk :foreground secondary-text)
    (skk-tut-hint-face :package ddskk :foreground foreground-muted)
    (skk-tut-key-bind-face :package ddskk :foreground primary-text)
    (skk-tut-question-face :package ddskk :foreground primary-text)
    (skk-inline-show-vertically-cand-face :package ddskk :foreground foreground :background surface-raised)
    (skk-inline-show-vertically-anno-face :package ddskk :foreground secondary-text)
    (skk-tooltip-show-at-point-cand-face :package ddskk :foreground foreground :background surface-raised)
    (skk-tooltip-show-at-point-anno-face :package ddskk :foreground secondary-text)
    (skk-henkan-show-candidates-buffer-cand-face :package ddskk :foreground foreground :background surface-raised)
    (skk-henkan-show-candidates-buffer-anno-face :package ddskk :foreground secondary-text)

    ;; Tempel fields.
    (tempel-field :package tempel :foreground primary-text :background primary-subtle)
    (tempel-form :package tempel :foreground secondary-text :background secondary-subtle)
    (tempel-default :package tempel :foreground foreground-secondary :background surface-raised)

    ;; Transient is used by Magit and is bundled with some Emacs versions.
    (transient-enabled-suffix :package transient :foreground secondary-on-strong :background secondary-strong)
    (transient-disabled-suffix :package transient :foreground primary-on-strong :background primary-strong)
    (transient-key-stay :package transient :foreground secondary-text)
    (transient-key-noop :package transient :foreground foreground-faint)
    (transient-key-return :package transient :foreground secondary-text)
    (transient-key-recurse :package transient :foreground primary-text)
    (transient-key-stack :package transient :foreground secondary-text)
    (transient-key-exit :package transient :foreground primary-text)

    ;; Folding, undo visualization, and editable grep buffers.
    (treesit-fold-replacement-face :package treesit-fold :foreground foreground-muted)
    (treesit-fold-replacement-mouse-face :package treesit-fold :foreground foreground-secondary)
    (vundo-highlight :package vundo :foreground primary-text)
    (vundo-saved :package vundo :foreground secondary-text)
    (wgrep-face :package wgrep :foreground secondary-on-strong :background secondary-strong)
    (wgrep-delete-face :package wgrep :foreground primary-on-strong :background primary-strong)
    (wgrep-file-face :package wgrep :foreground foreground :background surface-sunken)
    (wgrep-reject-face :package wgrep :foreground primary-text)
    (wgrep-done-face :package wgrep :foreground secondary-text))
  "Color-only declarations for external package faces.")

(defun complementary-light-package-face-rule (face)
  "Return the external package declaration for FACE, or nil."
  (assq face complementary-light-package-face-rules))

(defun complementary-light--package-rule-attributes (rule primary secondary)
  "Resolve color attributes in package RULE for PRIMARY and SECONDARY."
  (let (attributes)
    (dolist (attribute '(:foreground :background :distant-foreground) attributes)
      (when-let ((token (plist-get rule attribute)))
        (setq attributes
              (append attributes
                      (list attribute
                            (complementary-light-token token primary secondary))))))))

(defun complementary-light--package-face-spec (rule primary secondary)
  "Build one package face spec from RULE for PRIMARY and SECONDARY."
  (let* ((face (car rule))
         (colors (complementary-light--package-rule-attributes
                  (cdr rule) primary secondary))
         (line-token (or (plist-get (cdr rule) :foreground) 'border-strong))
         (line-color (complementary-light-token
                      line-token primary secondary))
         (default-spec (complementary-light--default-face-spec face)))
    (list
     face
     (if default-spec
         ;; Once the package has declared the face, reuse the built-in face
         ;; machinery to preserve every display-specific non-color attribute.
         (append
          (complementary-light--display-clauses
           face '((class color) (min-colors 257)) colors line-color)
          (complementary-light--display-clauses
           face '((class color) (min-colors 16)) colors line-color)
          (complementary-light--display-clauses
           face '((class mono)) nil line-color))
       ;; Register colors before a deferred package is loaded.  Its completed
       ;; defface is folded in by `complementary-light--package-after-load'.
       (list
        (list '((class color) (min-colors 257)) colors)
        (list '((class color) (min-colors 16)) colors)
        (list '((class mono)) nil))))))

(defun complementary-light-build-package-face-specs (primary secondary)
  "Build Custom Theme specs for package faces using PRIMARY and SECONDARY."
  (mapcar (lambda (rule)
            (complementary-light--package-face-spec
             rule primary secondary))
          complementary-light-package-face-rules))

(defvar complementary-light--package-theme-registrations nil
  "Palette and pending package faces recorded for each theme.")

(defun complementary-light-package-note-registration
    (&optional theme primary secondary neutral-palette accent-palettes)
  "Record pending package faces and palette data for THEME.
PRIMARY and SECONDARY select the accents.  NEUTRAL-PALETTE and
ACCENT-PALETTES are dynamically bound while deferred faces are rebuilt.
Omitted arguments retain compatibility with the light theme's original
internal call."
  (let* ((actual-theme (or theme 'complementary-light))
         (configuration
          (list
           :primary (or primary complementary-light--resolved-primary)
           :secondary (or secondary complementary-light--resolved-secondary)
           :neutral-palette
           (or neutral-palette complementary-light-neutral-palette)
           :accent-palettes
           (or accent-palettes complementary-light-palettes)
           :pending
           (cl-loop for rule in complementary-light-package-face-rules
                    for face = (car rule)
                    unless (complementary-light--default-face-spec face)
                    collect face))))
    (setf (alist-get actual-theme
                     complementary-light--package-theme-registrations
                     nil nil #'eq)
          configuration)))

(defun complementary-light--package-after-load (&optional _file)
  "Rebuild newly available package faces after a deferred library loads."
  (dolist (registration complementary-light--package-theme-registrations)
    (let* ((theme (car registration))
           (configuration (cdr registration))
           (pending (plist-get configuration :pending))
           (primary (plist-get configuration :primary))
           (secondary (plist-get configuration :secondary))
           (ready
            (cl-remove-if-not
             (lambda (face)
               (complementary-light--default-face-spec face))
             pending)))
      (when (and ready primary secondary)
        (setcdr
         registration
         (plist-put configuration :pending
                    (cl-set-difference pending ready)))
        (let ((complementary-light-neutral-palette
               (plist-get configuration :neutral-palette))
              (complementary-light-palettes
               (plist-get configuration :accent-palettes)))
          (apply #'custom-theme-set-faces
                 theme
                 (cl-loop for rule in complementary-light-package-face-rules
                          when (memq (car rule) ready)
                          collect (complementary-light--package-face-spec
                                   rule primary secondary))))))))

(add-hook 'after-load-functions #'complementary-light--package-after-load)

(provide 'complementary-light-packages)
;;; complementary-light-packages.el ends here
