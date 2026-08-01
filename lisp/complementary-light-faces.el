;;; complementary-light-faces.el --- Declarative face policy  -*- lexical-binding: t; -*-

;; Copyright (C) 2026
;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:

;; A rule changes only listed color attributes.  Missing attributes continue to
;; come from the original defface and inheritance chain.  Every face in the
;; recorded inventory receives an explicit status in `complementary-light-face-rules'.

;;; Code:

(require 'cl-lib)
(require 'complementary-light-palette)

(defvar complementary-light-generated-inventory)

(defconst complementary-light--faces-directory
  (file-name-directory (or load-file-name buffer-file-name))
  "Directory containing this module.")

(let ((inventory (expand-file-name
                  "../inventory/emacs-30.el"
                  complementary-light--faces-directory)))
  (unless (boundp 'complementary-light-generated-inventory)
    (load inventory nil nil t)))

(defconst complementary-light-non-color-attributes
  '(:family :foundry :width :height :weight :slant :underline :overline
    :strike-through :box :inverse-video :extend :inherit)
  "Attributes protected by the non-color preservation tests.")

(defconst complementary-light-non-color-attribute-allowlist
  nil
  "Intentional non-color changes made by this theme.
This is deliberately nil: all non-color attributes come from the default
`defface' specifications.")

(defconst complementary-light--declared-themed-rules
  '(
    ;; Foundation and generic UI.
    (default :status themed :foreground foreground :background background)
    (cursor :status themed :background cursor)
    (shadow :status themed :foreground foreground-muted)
    (link :status themed :foreground primary-text)
    (link-visited :status themed :foreground secondary-text)
    (highlight :status themed :background primary-medium :distant-foreground distant-foreground)
    (region :status themed :background region-background :distant-foreground distant-foreground)
    (secondary-selection :status themed :background secondary-subtle :distant-foreground distant-foreground)
    (match :status themed :background primary-medium :distant-foreground distant-foreground)
    (lazy-highlight :status themed :background secondary-medium :distant-foreground distant-foreground)
    (error :status themed :foreground primary-text)
    (warning :status themed :foreground secondary-text)
    (success :status themed :foreground foreground)
    (escape-glyph :status themed :foreground primary-text)
    (homoglyph :status themed :foreground primary-text)
    (nobreak-space :status themed :foreground primary-text)
    (trailing-whitespace :status themed :background primary-subtle)
    (vertical-border :status themed :foreground divider)
    (window-divider :status themed :foreground divider)
    (window-divider-first-pixel :status themed :foreground border-strong)
    (window-divider-last-pixel :status themed :foreground border)
    (internal-border :status themed :background border)
    (child-frame-border :status themed :background primary-border)
    (fringe :status themed :foreground foreground-muted :background surface-sunken)
    (line-number :status themed :foreground foreground-muted :background surface-sunken)
    (line-number-current-line :status themed :foreground primary-text :background surface-sunken)
    (fill-column-indicator :status themed :foreground divider)
    (header-line :status themed :foreground foreground-secondary :background surface-raised)
    (header-line-highlight :status themed :foreground primary-text :background primary-subtle)
    (mode-line :status themed :foreground foreground :background surface-raised)
    (mode-line-active :status themed :foreground foreground :background surface-raised)
    (mode-line-inactive :status themed :foreground inactive-foreground :background inactive-background)
    (minibuffer-prompt :status themed :foreground primary-text)
    (tooltip :status themed :foreground foreground :background surface-raised :distant-foreground distant-foreground)
    (menu :status themed :foreground foreground :background surface)
    (scroll-bar :status themed :foreground border-strong :background surface-sunken)
    (tool-bar :status themed :foreground foreground-secondary :background surface-raised)
    (tab-bar :status themed :foreground foreground-secondary :background surface-sunken)
    (tab-bar-tab :status themed :foreground primary-on-strong :background primary-strong)
    (tab-bar-tab-inactive :status themed :foreground inactive-foreground :background inactive-background)
    (tab-line :status themed :foreground foreground-secondary :background surface-sunken)
    (tab-line-tab :status themed :foreground primary-text :background surface)
    ;; Emacs declares only a background on this face.  Its inherited tab-line
    ;; foreground remains readable on the base surface in both polarities.
    (tab-line-tab-current :status themed :background surface)
    (tab-line-tab-inactive :status themed :foreground inactive-foreground :background inactive-background)
    (tab-line-highlight :status themed :background primary-subtle :distant-foreground distant-foreground)

    ;; Font Lock: intentionally keep variables, punctuation, comments and most
    ;; ordinary code neutral while declarations and named entities use accents.
    (font-lock-bracket-face :status themed :foreground foreground)
    (font-lock-builtin-face :status themed :foreground primary-text)
    (font-lock-comment-delimiter-face :status themed :foreground foreground-faint)
    (font-lock-comment-face :status themed :foreground foreground-muted)
    (font-lock-constant-face :status themed :foreground primary-text)
    (font-lock-delimiter-face :status themed :foreground foreground)
    (font-lock-doc-face :status themed :foreground foreground-muted)
    (font-lock-doc-markup-face :status themed :foreground primary-text)
    (font-lock-escape-face :status themed :foreground primary-text)
    (font-lock-function-call-face :status themed :foreground secondary-text)
    (font-lock-function-name-face :status themed :foreground secondary-text)
    (font-lock-keyword-face :status themed :foreground primary-text)
    (font-lock-misc-punctuation-face :status themed :foreground foreground-secondary)
    (font-lock-negation-char-face :status themed :foreground primary-text)
    (font-lock-number-face :status themed :foreground secondary-text)
    (font-lock-operator-face :status themed :foreground foreground)
    (font-lock-preprocessor-face :status themed :foreground primary-text)
    (font-lock-property-name-face :status themed :foreground secondary-text)
    (font-lock-property-use-face :status themed :foreground secondary-text)
    (font-lock-punctuation-face :status themed :foreground foreground-secondary)
    (font-lock-regexp-grouping-backslash :status themed :foreground primary-text)
    (font-lock-regexp-grouping-construct :status themed :foreground secondary-text)
    (font-lock-string-face :status themed :foreground secondary-text)
    (font-lock-type-face :status themed :foreground secondary-text)
    (font-lock-variable-name-face :status themed :foreground foreground)
    (font-lock-variable-use-face :status themed :foreground foreground)
    (font-lock-warning-face :status themed :foreground secondary-text)

    ;; Search, completion, navigation and help.
    (isearch :status themed :foreground primary-on-state :background primary-state :distant-foreground distant-foreground)
    (isearch-fail :status themed :background primary-medium :distant-foreground distant-foreground)
    (query-replace :status themed :foreground secondary-on-state :background secondary-state :distant-foreground distant-foreground)
    (completions-annotations :status themed :foreground foreground-muted)
    (completions-common-part :status themed :foreground primary-text)
    (completions-first-difference :status themed :foreground secondary-text)
    (completions-highlight :status themed :background completion-background :distant-foreground distant-foreground)
    (completion-preview :status themed :foreground foreground-muted)
    (completion-preview-common :status themed :foreground primary-text)
    (completion-preview-exact :status themed :foreground secondary-text)
    (completion-preview-highlight :status themed :background secondary-subtle :distant-foreground distant-foreground)
    (next-error :status themed :background primary-subtle :distant-foreground distant-foreground)
    (next-error-message :status themed :foreground primary-text)
    (xref-file-header :status themed :foreground primary-text)
    (xref-line-number :status themed :foreground foreground-muted)
    (xref-match :status themed :background primary-subtle :distant-foreground distant-foreground)
    (help-argument-name :status themed :foreground secondary-text)
    (help-key-binding :status themed :foreground primary-text :background primary-subtle)
    (help-for-help-header :status themed :foreground primary-text)
    (info-header-node :status themed :foreground primary-text)
    (info-header-xref :status themed :foreground secondary-text)
    (info-index-match :status themed :background primary-subtle :distant-foreground distant-foreground)
    (info-menu-header :status themed :foreground primary-text)
    (info-menu-star :status themed :foreground secondary-text)
    (info-node :status themed :foreground primary-text)
    (info-title-1 :status themed :foreground primary-text)
    (info-title-2 :status themed :foreground secondary-text)
    (info-title-3 :status themed :foreground primary-text)
    (info-title-4 :status themed :foreground secondary-text)
    (apropos-function-button :status themed :foreground secondary-text)
    (apropos-keybinding :status themed :foreground primary-text)
    (apropos-property :status themed :foreground secondary-text)
    (apropos-symbol :status themed :foreground primary-text)

    ;; Editing aids and diagnostics.  Non-color state attributes come only
    ;; from the original defface specifications.
    (hl-line :status themed :background hl-line-background :distant-foreground distant-foreground)
    (show-paren-match :status themed :background secondary-medium :distant-foreground distant-foreground)
    (show-paren-mismatch :status themed :background primary-subtle :distant-foreground distant-foreground)
    (pulse-highlight-start-face :status themed :background primary-medium :distant-foreground distant-foreground)
    (hi-yellow :status themed :background primary-subtle :distant-foreground distant-foreground)
    (hi-pink :status themed :background secondary-subtle :distant-foreground distant-foreground)
    (hi-green :status themed :background secondary-subtle :distant-foreground distant-foreground)
    (hi-blue :status themed :background primary-subtle :distant-foreground distant-foreground)
    (flymake-error :status themed :foreground primary-text)
    (flymake-warning :status themed :foreground secondary-text)
    (flymake-note :status themed :foreground foreground-secondary)
    (flyspell-incorrect :status themed)
    (flyspell-duplicate :status themed)
    (whitespace-space :status themed :foreground foreground-faint)
    (whitespace-tab :status themed :foreground foreground-faint)
    (whitespace-newline :status themed :foreground foreground-faint)
    (whitespace-trailing :status themed :background primary-subtle)
    (whitespace-line :status themed :foreground secondary-text)
    (whitespace-empty :status themed :background primary-subtle)
    (whitespace-indentation :status themed :foreground foreground-faint)
    (whitespace-space-before-tab :status themed :background secondary-subtle)
    (whitespace-space-after-tab :status themed :background secondary-subtle)

    ;; Diff/VC/compilation: hues are paired accents; shape carries semantics.
    (diff-added :status themed :foreground secondary-text :background secondary-subtle)
    (diff-removed :status themed :foreground primary-text :background primary-subtle)
    (diff-changed :status themed :foreground primary-text :background secondary-subtle)
    (diff-refine-added :status themed :foreground secondary-on-medium :background secondary-medium)
    (diff-refine-removed :status themed :foreground primary-on-medium :background primary-medium)
    (diff-refine-changed :status themed :foreground primary-text :background secondary-medium)
    (diff-header :status themed :foreground foreground-secondary :background surface-sunken)
    (diff-file-header :status themed :foreground primary-text :background surface-raised)
    (diff-hunk-header :status themed :foreground secondary-text :background surface-raised)
    (diff-context :status themed :foreground foreground-secondary)
    (diff-indicator-added :status themed :foreground secondary-text)
    (diff-indicator-removed :status themed :foreground primary-text)
    (diff-indicator-changed :status themed :foreground primary-text)
    (compilation-error :status themed :foreground primary-text)
    (compilation-warning :status themed :foreground secondary-text)
    (compilation-info :status themed :foreground foreground-secondary)
    (compilation-line-number :status themed :foreground secondary-text)
    (compilation-column-number :status themed :foreground foreground-muted)
    ;; These built-in faces declare foreground only, so do not pair an
    ;; on-strong foreground with a background that topology filtering removes.
    (compilation-mode-line-exit :status themed :foreground foreground)
    (compilation-mode-line-fail :status themed :foreground primary-text)
    (compilation-mode-line-run :status themed :foreground primary-text)
    (grep-context-face :status themed :foreground foreground-muted)
    (grep-error-face :status themed :foreground primary-text)
    (grep-hit-face :status themed :foreground secondary-text)
    (grep-match-face :status themed :background primary-subtle :distant-foreground distant-foreground)
    (vc-dir-header :status themed :foreground primary-text)
    (vc-dir-header-value :status themed :foreground secondary-text)
    (vc-dir-status-edited :status themed :foreground primary-text)
    (vc-dir-status-warning :status themed :foreground secondary-text)

    ;; Ediff keeps its original extend, weight, underline, inverse-video and
    ;; stipple behavior.  Only colors are mapped onto contrast-checked roles.
    (ediff-current-diff-A :status themed :foreground primary-text :background primary-subtle)
    (ediff-current-diff-B :status themed :foreground secondary-text :background secondary-subtle)
    (ediff-current-diff-C :status themed :foreground foreground :background selection-neutral)
    (ediff-current-diff-Ancestor :status themed :foreground foreground-secondary :background surface-raised)
    (ediff-fine-diff-A :status themed :foreground primary-on-medium :background primary-medium)
    (ediff-fine-diff-B :status themed :foreground secondary-on-medium :background secondary-medium)
    (ediff-fine-diff-C :status themed :foreground foreground :background selection-neutral)
    (ediff-fine-diff-Ancestor :status themed :foreground foreground-secondary :background surface-raised)
    (ediff-even-diff-A :status themed :foreground primary-text :background surface-raised :distant-foreground distant-foreground)
    (ediff-even-diff-B :status themed :foreground secondary-text :background surface-raised :distant-foreground distant-foreground)
    (ediff-even-diff-C :status themed :foreground foreground :background surface-raised :distant-foreground distant-foreground)
    (ediff-even-diff-Ancestor :status themed :foreground foreground-secondary :background surface-raised :distant-foreground distant-foreground)
    (ediff-odd-diff-A :status themed :foreground primary-text :background surface-sunken :distant-foreground distant-foreground)
    (ediff-odd-diff-B :status themed :foreground secondary-text :background surface-sunken :distant-foreground distant-foreground)
    (ediff-odd-diff-C :status themed :foreground foreground :background surface-sunken :distant-foreground distant-foreground)
    (ediff-odd-diff-Ancestor :status themed :foreground foreground-secondary :background surface-sunken :distant-foreground distant-foreground)

    ;; Structured text and common bundled modes.
    (outline-1 :status themed :foreground primary-text)
    (outline-2 :status themed :foreground secondary-text)
    (outline-3 :status themed :foreground primary-text)
    (outline-4 :status themed :foreground secondary-text)
    (outline-5 :status themed :foreground primary-text)
    (outline-6 :status themed :foreground secondary-text)
    (outline-7 :status themed :foreground primary-text)
    (outline-8 :status themed :foreground secondary-text)
    (org-level-1 :status themed :foreground primary-text)
    (org-level-2 :status themed :foreground secondary-text)
    (org-level-3 :status themed :foreground primary-text)
    (org-level-4 :status themed :foreground secondary-text)
    (org-block :status themed :foreground foreground-secondary :background surface-raised)
    (org-block-begin-line :status themed :foreground foreground-muted :background surface-sunken)
    (org-block-end-line :status themed :foreground foreground-muted :background surface-sunken)
    (org-code :status themed :foreground secondary-text)
    (org-verbatim :status themed :foreground primary-text)
    (org-link :status themed :foreground primary-text)
    (org-date :status themed :foreground secondary-text)
    (org-todo :status themed :foreground primary-text)
    (org-done :status themed :foreground foreground)
    (org-checkbox :status themed :foreground primary-text)
    (org-tag :status themed :foreground secondary-text)
    (org-document-title :status themed :foreground primary-text)
    (org-document-info :status themed :foreground foreground-secondary)
    (org-meta-line :status themed :foreground foreground-muted)
    (org-special-keyword :status themed :foreground primary-text)
    (nxml-element-local-name :status themed :foreground secondary-text)
    (nxml-attribute-local-name :status themed :foreground secondary-text)
    (nxml-tag-delimiter :status themed :foreground foreground-secondary)
    (nxml-tag-slash :status themed :foreground foreground-secondary)
    (nxml-entity-ref-name :status themed :foreground primary-text)
    (css-selector :status themed :foreground secondary-text)
    (css-property :status themed :foreground primary-text)
    (sh-heredoc :status themed :foreground secondary-text)
    (sh-quoted-exec :status themed :foreground primary-text)
    (eshell-prompt :status themed :foreground primary-text)
    (eshell-ls-directory :status themed :foreground secondary-text)
    (eshell-ls-symlink :status themed :foreground primary-text)
    (comint-highlight-prompt :status themed :foreground primary-text)
    (comint-highlight-input :status themed :foreground secondary-text)

    ;; Mail, chat and web-security indicators bundled with Emacs.
    (message-cited-text-1 :status themed :foreground primary-text)
    (message-cited-text-2 :status themed :foreground secondary-text)
    (message-cited-text-3 :status themed :foreground foreground-muted)
    (message-cited-text-4 :status themed :foreground foreground-secondary)
    (message-header-cc :status themed :foreground secondary-text)
    (message-header-name :status themed :foreground foreground-muted)
    (message-header-newsgroups :status themed :foreground primary-text)
    (message-header-other :status themed :foreground foreground-secondary)
    (message-header-subject :status themed :foreground primary-text)
    (message-header-to :status themed :foreground secondary-text)
    (message-header-xheader :status themed :foreground primary-text)
    (erc-direct-msg-face :status themed :foreground primary-text)
    (erc-error-face :status themed :foreground primary-text)
    (erc-fool-face :status themed :foreground foreground-muted)
    (erc-input-face :status themed :foreground foreground)
    (erc-keyword-face :status themed :foreground primary-text)
    (erc-my-nick-face :status themed :foreground secondary-text)
    (erc-nick-msg-face :status themed :foreground primary-text)
    (erc-notice-face :status themed :foreground foreground-secondary)
    (erc-pal-face :status themed :foreground secondary-text)
    (erc-prompt-face :status themed :foreground primary-on-strong :background primary-strong)
    (erc-timestamp-face :status themed :foreground foreground-muted)
    (eww-invalid-certificate :status themed :foreground primary-text)
    (eww-valid-certificate :status themed :foreground foreground)

    ;; Tables, buffers, Customize and package UI.
    (dired-directory :status themed :foreground secondary-text)
    (dired-symlink :status themed :foreground primary-text)
    (dired-header :status themed :foreground primary-text)
    (dired-mark :status themed :foreground primary-text)
    (dired-marked :status themed :foreground primary-text :background primary-subtle)
    (dired-flagged :status themed :foreground primary-text)
    (dired-broken-symlink :status themed :foreground primary-text)
    (ibuffer-title-face :status themed :foreground primary-text)
    (ibuffer-marked-face :status themed :foreground primary-text :background primary-subtle)
    (ibuffer-deletion-face :status themed :foreground primary-text)
    (tabulated-list-fake-header :status themed :foreground foreground-secondary :background surface-raised)
    (custom-button :status themed :foreground primary-on-strong :background primary-strong)
    (custom-button-mouse :status themed :foreground primary-on-medium :background primary-medium)
    (custom-button-pressed :status themed :foreground secondary-on-strong :background secondary-strong)
    (custom-group-tag :status themed :foreground primary-text)
    (custom-variable-tag :status themed :foreground secondary-text)
    (custom-state :status themed :foreground secondary-text)
    (custom-invalid :status themed :foreground primary-text)
    (custom-modified :status themed :foreground primary-text :background primary-subtle)
    (custom-set :status themed :foreground foreground)
    (package-name :status themed :foreground primary-text)
    (package-description :status themed :foreground foreground-secondary)
    (package-status-installed :status themed :foreground foreground)
    (package-status-available :status themed :foreground primary-text)
    (package-status-dependency :status themed :foreground foreground-muted)
    (package-status-disabled :status themed :foreground foreground-muted)
    (package-status-held :status themed :foreground secondary-text)
    (package-status-incompat :status themed :foreground primary-text)
    (package-status-new :status themed :foreground secondary-text)
    (package-status-obsolete :status themed :foreground primary-text)
    (package-status-unsigned :status themed :foreground secondary-text)
    )
  "Face-specific color declarations maintained by hand.")

(defconst complementary-light--preserve-exact
  '(bold bold-italic fixed-pitch fixed-pitch-serif italic variable-pitch
    variable-pitch-text variable-pitch-text-variable-pitch)
  "Faces whose font metrics or non-color identity must remain untouched.")

(defun complementary-light--external-semantic-face-p (face)
  "Return non-nil when FACE carries colors defined by an external protocol."
  (string-match-p
   (rx bos (or "ansi-color-" "term-color-" "xterm-color-"
               "compilation-shell-minor-mode-"))
   (symbol-name face)))

(defun complementary-light--inventory-faces ()
  "Return the face entries in the recorded inventory."
  (plist-get complementary-light-generated-inventory :faces))

(defun complementary-light--default-inherit-target (tree)
  "Return the first literal `:inherit' target found in defface TREE."
  (cond ((not (consp tree)) nil)
        ((and (eq (car tree) :inherit) (cadr tree)) (cadr tree))
        (t (or (complementary-light--default-inherit-target (car tree))
               (complementary-light--default-inherit-target (cdr tree))))))

(defconst complementary-light--color-attributes
  '(:foreground :background :distant-foreground)
  "Color attributes that the theme may replace.")

(defun complementary-light--tree-contains-symbol-p (tree symbol)
  "Return non-nil when TREE contains SYMBOL."
  (cond ((eq tree symbol) t)
        ((consp tree)
         (or (complementary-light--tree-contains-symbol-p (car tree) symbol)
             (complementary-light--tree-contains-symbol-p (cdr tree) symbol)))
        (t nil)))

(defun complementary-light--plist-delete (plist property)
  "Return a copy of PLIST without PROPERTY and its value."
  (let (result)
    (while plist
      (unless (eq (car plist) property)
        (setq result (append result (list (car plist) (cadr plist)))))
      (setq plist (cddr plist)))
    result))

(defun complementary-light--default-declares-color-p
    (face properties attribute)
  "Return non-nil when FACE's recorded defface declares ATTRIBUTE.
PROPERTIES is the inventory property list for FACE.  `default' is the
root of the theme palette and therefore intentionally supplies both of
its fundamental colors even though its built-in defface is empty."
  (or (and (eq face 'default)
           (memq attribute '(:foreground :background)))
      (complementary-light--tree-contains-symbol-p
       (plist-get properties :default-spec) attribute)))

(defun complementary-light--sanitize-declared-rule
    (face properties declared inherit)
  "Restrict DECLARED to FACE's built-in color topology.
PROPERTIES contains the inventory metadata and INHERIT is the recorded
inheritance target.  A declaration that has no color attributes after
filtering becomes an explicit `inherit' or `preserve' classification."
  (let ((rule (copy-tree declared)))
    (dolist (attribute complementary-light--color-attributes)
      (unless (complementary-light--default-declares-color-p
               face properties attribute)
        (setq rule
              (cons face
                    (complementary-light--plist-delete
                     (cdr rule) attribute)))))
    (if (cl-some (lambda (attribute) (plist-member (cdr rule) attribute))
                 complementary-light--color-attributes)
        rule
      (if inherit
          (list face :status 'inherit :target inherit
                :reason (concat
                         "Use the built-in inheritance chain; its defface "
                         "does not introduce a color attribute here."))
        (list face :status 'preserve
              :reason (concat
                       "Retain the built-in colors; its defface does not "
                       "declare a theme-replaceable color attribute."))))))

(defun complementary-light--inventory-rule (entry)
  "Create an explicit classification rule for inventory ENTRY."
  (let* ((face (car entry))
         (props (cdr entry))
         (declared (assq face complementary-light--declared-themed-rules))
         (alias (or (plist-get props :alias-of)
                    (plist-get props :obsolete-alias-of)))
         (inherit (complementary-light--default-inherit-target
                   (plist-get props :default-spec))))
    (cond
     (declared
      (complementary-light--sanitize-declared-rule
       face props declared inherit))
     (alias (list face :status 'alias :target alias
                  :reason "Preserve the built-in face alias relationship."))
     ((complementary-light--external-semantic-face-p face)
      (list face :status 'external-semantic
            :reason "Preserve color semantics supplied by external terminal programs."))
     ((memq face complementary-light--preserve-exact)
      (list face :status 'preserve
            :reason "Preserve the user's font family, metrics, and original attributes."))
     (inherit
      (list face :status 'inherit :target inherit
            :reason "Use the color behavior of the recorded defface inheritance chain."))
     (t
      (list face :status 'preserve
            :reason "Retain its recorded defface colors and attributes; this face has no theme-owned two-accent role.")))))

(defconst complementary-light-face-rules
  (mapcar #'complementary-light--inventory-rule
          (complementary-light--inventory-faces))
  "Complete classification of the recorded built-in named-face inventory.")

(defun complementary-light-face-rule (face)
  "Return the declaration for FACE, or nil when it is not recorded."
  (assq face complementary-light-face-rules))

(defun complementary-light-face-status (face)
  "Return classification status for FACE."
  (plist-get (cdr (complementary-light-face-rule face)) :status))

(defun complementary-light--rule-attributes (rule primary secondary)
  "Resolve the color attributes in RULE for PRIMARY and SECONDARY."
  (let (attributes)
    (dolist (mapping '((:foreground . :foreground)
                       (:background . :background)
                       (:distant-foreground . :distant-foreground)))
      (when-let ((token (plist-get rule (car mapping))))
        (setq attributes
              (append attributes
                      (list (cdr mapping)
                            (complementary-light-token token primary secondary))))))
    attributes))

(defun complementary-light--safe-template-data-p (object)
  "Return non-nil when OBJECT is inert data safe to copy from a variable."
  (or (null object) (symbolp object) (stringp object) (numberp object)
      (and (consp object)
           (complementary-light--safe-template-data-p (car object))
           (complementary-light--safe-template-data-p (cdr object)))))

(defun complementary-light--safe-template-value (form)
  "Evaluate the small, side-effect-free subset used in defface templates.
Unsupported FORM values become nil instead of running arbitrary source code."
  (cond
   ((or (numberp form) (stringp form) (null form) (eq form t)) form)
   ((eq form 'emacs-major-version) emacs-major-version)
   ((eq form 'emacs-minor-version) emacs-minor-version)
   ((symbolp form)
    (when (and (boundp form)
               (complementary-light--safe-template-data-p
                (symbol-value form)))
      (copy-tree (symbol-value form))))
   ((eq (car-safe form) 'quote) (copy-tree (cadr form)))
   ((eq (car-safe form) '>=)
    (>= (or (complementary-light--safe-template-value (nth 1 form)) 0)
        (or (complementary-light--safe-template-value (nth 2 form)) 0)))
   ((eq (car-safe form) 'and)
    (let ((value t) (tail (cdr form)))
      (while (and tail value)
        (setq value (complementary-light--safe-template-value (pop tail))))
      value))
   ((eq (car-safe form) 'if)
    (complementary-light--safe-template-value
     (if (complementary-light--safe-template-value (nth 1 form))
         (nth 2 form) (nth 3 form))))
   ((eq (car-safe form) 'cons)
    (cons (complementary-light--safe-template-value (nth 1 form))
          (complementary-light--safe-template-value (nth 2 form))))
   (t nil)))

(defun complementary-light--expand-backquote-template (object)
  "Expand safe comma forms in backquoted defface OBJECT."
  (cond
   ((not (consp object)) object)
   ((eq (car object) (intern ","))
    (complementary-light--safe-template-value (cadr object)))
   ((eq (car object) (intern ",@"))
    (complementary-light--safe-template-value (cadr object)))
   (t
    (let ((head (car object)) (tail (cdr object)))
      (if (and (consp head) (eq (car head) (intern ",@")))
          (append (complementary-light--safe-template-value (cadr head))
                  (complementary-light--expand-backquote-template tail))
        (cons (complementary-light--expand-backquote-template head)
              (complementary-light--expand-backquote-template tail)))))))

(defun complementary-light--unquote (object)
  "Return literal OBJECT with one leading quote or backquote removed."
  (cond ((and (consp object) (eq (car object) 'quote)) (cadr object))
        ((and (consp object) (eq (car object) (intern "`")))
         (complementary-light--expand-backquote-template (cadr object)))
        (t object)))

(defun complementary-light--default-face-spec (face)
  "Return the recorded default defface spec for FACE."
  (let ((entry (assq face (complementary-light--inventory-faces))))
    (complementary-light--unquote
     (or (get face 'face-defface-spec)
         (plist-get (cdr entry) :default-spec)))))

(defun complementary-light--sanitize-line-color (attribute value replacement)
  "Preserve ATTRIBUTE's shape in VALUE while replacing its line color.
REPLACEMENT is a registered palette value."
  (if (not (memq attribute '(:underline :overline :strike-through :box)))
      value
    (cond ((stringp value) replacement)
          ((and (listp value) (plist-member value :color))
           (plist-put (copy-tree value) :color replacement))
          (t value))))

(defun complementary-light--non-color-plist (attributes line-color)
  "Copy protected non-color keys from face ATTRIBUTES.
Replace only embedded line colors with LINE-COLOR, preserving style and width."
  (let (result)
    (dolist (attribute complementary-light-non-color-attributes result)
      (when (plist-member attributes attribute)
        (setq result (append result
                             (list attribute
                                   (complementary-light--sanitize-line-color
                                    attribute
                                    (plist-get attributes attribute)
                                    line-color))))))))

(defun complementary-light--merge-plists (base override)
  "Return BASE with keys from OVERRIDE added or replaced."
  (let ((result (copy-tree base)))
    (while override
      (setq result (plist-put result (car override) (cadr override))
            override (cddr override)))
    result))

(defun complementary-light--filter-color-attributes
    (face color-attributes original-attributes default-attributes)
  "Keep colors used by FACE in the corresponding built-in clause.
COLOR-ATTRIBUTES is the resolved theme color plist.  The permitted color
shape comes from ORIGINAL-ATTRIBUTES and DEFAULT-ATTRIBUTES.  `default'
is the sole exception because it establishes the root palette."
  (let (result)
    (dolist (attribute complementary-light--color-attributes result)
      (when (and (plist-member color-attributes attribute)
                 (or (and (eq face 'default)
                          (memq attribute '(:foreground :background)))
                     (plist-member original-attributes attribute)
                     (plist-member default-attributes attribute)))
        (setq result
              (append result
                      (list attribute
                            (plist-get color-attributes attribute))))))))

(defun complementary-light--combine-display (theme-display original-display)
  "Combine THEME-DISPLAY with ORIGINAL-DISPLAY conditions."
  (if (memq original-display '(t default nil))
      theme-display
    (append theme-display original-display)))

(defun complementary-light--clause-attributes (clause)
  "Return the attribute plist from a defface CLAUSE.
Emacs accepts both (DISPLAY :key value) and (DISPLAY (:key value))."
  (let ((tail (cdr clause)))
    (if (and (= (length tail) 1) (listp (car tail)))
        (car tail)
      tail)))

(defun complementary-light--display-clauses
    (face display color-attributes line-color)
  "Build DISPLAY clauses for FACE preserving its default non-color attributes."
  (let* ((originals (complementary-light--default-face-spec face))
         (default-clause (cl-find-if (lambda (item)
                                       (eq (car-safe item) 'default))
                                     originals))
         (default-attributes
          (and default-clause
               (complementary-light--clause-attributes default-clause)))
         (base (and default-attributes
                    (complementary-light--non-color-plist
                     default-attributes line-color)))
         clauses fallback-seen)
    ;; Specific selectors precede the generic t/default fallback.  A `default'
    ;; clause supplies base attributes to every branch rather than acting as an
    ;; early first-match clause.
    (dolist (original originals)
      (when (and (consp original)
                 (not (memq (car original) '(default t))))
        (let* ((original-attributes
                (complementary-light--clause-attributes original))
               (non-color (complementary-light--non-color-plist
                           original-attributes line-color))
               (colors (complementary-light--filter-color-attributes
                        face color-attributes original-attributes
                        default-attributes)))
          (push (list (complementary-light--combine-display
                       display (car original))
                      (complementary-light--merge-plists
                       (complementary-light--merge-plists base non-color)
                       colors))
                clauses))))
    (dolist (original originals)
      (when (eq (car-safe original) t)
        (setq fallback-seen t)
        (let* ((original-attributes
                (complementary-light--clause-attributes original))
               (non-color (complementary-light--non-color-plist
                           original-attributes line-color))
               (colors (complementary-light--filter-color-attributes
                        face color-attributes original-attributes
                        default-attributes)))
          (push (list display
                      (complementary-light--merge-plists
                       (complementary-light--merge-plists base non-color)
                       colors))
                clauses))))
    (unless fallback-seen
      (push (list display
                  (complementary-light--merge-plists
                   base
                   (complementary-light--filter-color-attributes
                    face color-attributes nil default-attributes)))
            clauses))
    (nreverse clauses)))

(defun complementary-light--terminal-256-clauses (clauses)
  "Make every explicit text pair in xterm-256 display CLAUSES contrast-safe."
  (mapcar
   (lambda (clause)
     (list (car clause)
           (complementary-light-terminal-adjust-attributes (cadr clause))))
   clauses))

(defun complementary-light-build-face-specs (primary secondary)
  "Build Custom Theme specs for the themed PRIMARY/SECONDARY pair."
  (let (specs)
    (dolist (rule complementary-light-face-rules (nreverse specs))
      (when (eq (plist-get (cdr rule) :status) 'themed)
        (let* ((face (car rule))
               (truecolor (complementary-light--rule-attributes
                           (cdr rule) primary secondary))
               ;; Monochrome receives no theme-owned non-color attributes.
               (mono nil)
               (line-token (or (plist-get (cdr rule) :foreground)
                               'border-strong))
               (line-color (complementary-light-token
                            line-token primary secondary))
               (clauses
                (append
                 (complementary-light--display-clauses
                  face '((class color) (min-colors 257)) truecolor line-color)
                 (complementary-light--terminal-256-clauses
                  (complementary-light--display-clauses
                   face '((class color) (min-colors 256)) truecolor line-color))
                 (complementary-light--display-clauses
                  face '((class color) (min-colors 16)) truecolor line-color)
                 (complementary-light--display-clauses
                  face '((class mono)) mono line-color))))
          (push (list face clauses)
                specs))))))

(provide 'complementary-light-faces)
;;; complementary-light-faces.el ends here
