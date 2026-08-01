;;; complementary-light-generate-faces.el --- Build the bundled face inventory  -*- lexical-binding: t; -*-

;; Copyright (C) 2026
;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:

;; Read the Emacs Lisp shipped below `lisp-directory' without evaluating it.
;; The Lisp reader, rather than a regular expression, finds face declarations.
;; Startup faces and face aliases are then merged with the source scan.

;;; Code:

(require 'cl-lib)
(require 'json)

(defconst complementary-light-inventory-methods
  '(startup-face-list elisp-reader defface custom-declare-face
    define-obsolete-face-alias face-alias-property)
  "Discovery methods used by the inventory generator.")

(defun complementary-light-inventory--literal-symbol (object)
  "Return the literal symbol represented by OBJECT, or nil."
  (cond ((symbolp object) object)
        ((and (consp object) (eq (car object) 'quote)
              (symbolp (cadr object)))
         (cadr object))))

(defun complementary-light-inventory--record
    (table name file library kind target line &optional default-spec)
  "Record face NAME from FILE and LIBRARY in TABLE.
KIND describes the declaration; TARGET is an alias target; LINE is its line."
  (when (and (symbolp name) (not (keywordp name)))
    (let* ((old (gethash name table))
           (entry (or old (list name :library library :source-file file
                                :line line :alias-of nil
                                :obsolete-alias-of nil
                                :loaded-at-startup nil :default-spec nil
                                :methods nil)))
           (name-cell (car entry))
           (properties (cdr entry)))
      (unless (plist-get properties :source-file)
        (setq properties (plist-put properties :source-file file)))
      (unless (plist-get properties :library)
        (setq properties (plist-put properties :library library)))
      (unless (plist-get properties :line)
        (setq properties (plist-put properties :line line)))
      (when (and default-spec (not (plist-get properties :default-spec)))
        (setq properties (plist-put properties :default-spec default-spec)))
      (setq properties
            (plist-put properties :methods
                       (cl-adjoin kind (plist-get properties :methods))))
      (pcase kind
        ('alias (setq properties (plist-put properties :alias-of target)))
        ('obsolete-alias
         (setq properties
               (plist-put properties :obsolete-alias-of target))))
      (puthash name (cons name-cell properties) table))))

(defun complementary-light-inventory--walk-form (form table file library line)
  "Walk Lisp FORM and add face declarations to TABLE.
FILE, LIBRARY and LINE describe the containing top-level form."
  (when (and (consp form) (not (eq (car form) 'quote)))
    (pcase (car form)
      ((or 'defface 'custom-declare-face)
       (let ((name (complementary-light-inventory--literal-symbol (cadr form))))
         (complementary-light-inventory--record
          table name file library (car form) nil line (caddr form))))
      ('define-obsolete-face-alias
       (let ((name (complementary-light-inventory--literal-symbol (cadr form)))
             (target (complementary-light-inventory--literal-symbol (caddr form))))
         (complementary-light-inventory--record
          table name file library 'obsolete-alias target line)))
      ('put
       (when (eq (complementary-light-inventory--literal-symbol (caddr form))
                 'face-alias)
         (let ((name (complementary-light-inventory--literal-symbol (cadr form)))
               (target (complementary-light-inventory--literal-symbol
                        (car (cdddr form)))))
           (complementary-light-inventory--record
            table name file library 'alias target line)))))
    ;; Face declarations are sometimes wrapped in conditional or compile-time
    ;; forms.  Restrict descent to code containers: recursively traversing data
    ;; tables both creates false positives and can exceed Lisp nesting limits.
    (when (memq (car form)
                '(progn prog1 prog2 eval-and-compile eval-when-compile
                  when unless if cond pcase let let* condition-case))
      (let ((children (cdr form)))
        (while (consp children)
          (complementary-light-inventory--walk-form
           (car children) table file library line)
          (setq children (cdr children)))))))

(defun complementary-light-inventory--scan-file (file table)
  "Read FILE as Lisp and add declarations to TABLE."
  (with-temp-buffer
    (condition-case err
        (progn
          (let ((inhibit-message t))
            (insert-file-contents file))
          (goto-char (point-min))
          (let ((library (file-name-base
                          (file-name-sans-extension file))))
            (condition-case nil
                (while t
                  (skip-chars-forward " \t\r\n")
                  (let ((line (line-number-at-pos))
                        (form (read (current-buffer))))
                    (complementary-light-inventory--walk-form
                     form table file library line)))
              (end-of-file nil))))
      (error
       (message "Inventory: skipped unreadable %s: %s"
                file (error-message-string err))))))

(defun complementary-light-inventory--source-files ()
  "Return shipped Emacs Lisp source files below `lisp-directory'."
  (sort (directory-files-recursively
         lisp-directory "\\.el\\(?:\\.gz\\)?\\'") #'string<))

(defun complementary-light-inventory-discover ()
  "Return a sorted inventory of built-in named faces for this Emacs."
  (let ((table (make-hash-table :test #'eq)))
    (dolist (face (face-list))
      (let* ((source (symbol-file face 'face))
             (entry (list face :library (and source (file-name-base source))
                          :source-file source :line nil
                          :alias-of (get face 'face-alias)
                          :obsolete-alias-of nil
                          :loaded-at-startup t
                          :default-spec (get face 'face-defface-spec)
                          :methods '(startup-face-list))))
        (puthash face entry table)))
    (dolist (file (complementary-light-inventory--source-files))
      (complementary-light-inventory--scan-file file table))
    (mapatoms
     (lambda (symbol)
       (when-let ((target (get symbol 'face-alias)))
         (complementary-light-inventory--record
          table symbol (symbol-file symbol 'face) nil 'alias target nil))))
    (let (items)
      (maphash (lambda (_ entry) (push entry items)) table)
      (sort items (lambda (a b)
                    (string< (symbol-name (car a))
                             (symbol-name (car b))))))))

(defun complementary-light-inventory--environment ()
  "Return the inventory environment metadata plist."
  (let* ((source-files (complementary-light-inventory--source-files))
         (el (cl-count-if (lambda (f) (string-suffix-p ".el" f)) source-files))
         (el-gz (- (length source-files) el)))
    (list :emacs-version emacs-version
          :emacs-major-version emacs-major-version
          :emacs-minor-version emacs-minor-version
          :emacs-build-number emacs-build-number
          :system-type system-type
          :window-system window-system
          :display-color-cells (display-color-cells)
          :graphic-display (display-graphic-p)
          :terminal-display (not (display-graphic-p))
          :daemon-mode (daemonp)
          :daemon-supported (fboundp 'daemonp)
          :gui-build (or (featurep 'pgtk) (featurep 'x) (featurep 'ns)
                         (featurep 'w32))
          :gui-environment (delq nil (list (getenv "DISPLAY")
                                           (getenv "WAYLAND_DISPLAY")))
          :terminal-capable t
          :lisp-directory lisp-directory
          :el-source-count el
          :el-gz-source-count el-gz
          :load-path load-path
          :bundled-packages (and (boundp 'package--builtin-versions)
                                 package--builtin-versions)
          :methods complementary-light-inventory-methods)))

(defun complementary-light-inventory-write (output)
  "Write the current Emacs face inventory to OUTPUT."
  (interactive "FInventory output: ")
  (let* ((items (complementary-light-inventory-discover))
         (aliases (cl-count-if
                   (lambda (e) (or (plist-get (cdr e) :alias-of)
                                   (plist-get (cdr e) :obsolete-alias-of)))
                   items))
         (unknown-source (cl-count-if
                          (lambda (e) (not (plist-get (cdr e) :source-file)))
                          items))
         (data (list :metadata
                     (append (complementary-light-inventory--environment)
                             (list :generated-at
                                   (format-time-string "%Y-%m-%dT%H:%M:%S%z")
                                   :face-count (length items)
                                   :alias-count aliases
                                   :unknown-source-count unknown-source))
                     :faces items)))
    (make-directory (file-name-directory output) t)
    (with-temp-file output
      (insert ";;; current-generated.el --- Generated built-in face inventory  -*- lexical-binding: t; -*-\n\n")
      (insert ";; Generated by tools/complementary-light-generate-faces.el.\n")
      (insert ";; Do not classify new faces automatically; regenerate, review, and update rules.\n\n")
      (insert "(defconst complementary-light-generated-inventory\n  '")
      (let ((print-length nil) (print-level nil))
        (pp data (current-buffer)))
      (insert "  \"Built-in named faces discovered in the recorded Emacs environment.\")\n\n")
      (insert "(provide 'complementary-light-current-inventory)\n")
      (insert ";;; current-generated.el ends here\n"))
    data))

(provide 'complementary-light-generate-faces)
;;; complementary-light-generate-faces.el ends here
