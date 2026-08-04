;;; complementary-light-attributes-test.el --- Non-color preservation  -*- lexical-binding: t; -*-

(require 'complementary-light-test-helper)

(defun complementary-light-test--attribute-snapshot (faces)
  "Snapshot direct and effective non-color attributes for FACES."
  (cl-loop for face in faces when (facep face)
           collect
           (cons face
                 (cl-loop for attribute in complementary-light-non-color-attributes
                          collect (list attribute
                                        (face-attribute face attribute nil nil)
                                        (face-attribute face attribute nil t))))))

(defun complementary-light-test--allowed-attribute-p (face attribute)
  "Return non-nil if FACE ATTRIBUTE is intentionally changed."
  (cl-some (lambda (entry)
             (and (eq (nth 0 entry) face) (eq (nth 1 entry) attribute)
                  (stringp (plist-get (nthcdr 2 entry) :reason))))
           complementary-light-non-color-attribute-allowlist))

(defun complementary-light-test--attribute-shape (attribute value)
  "Return VALUE normalized for color-only differences in ATTRIBUTE."
  (if (not (memq attribute '(:underline :overline :strike-through :box)))
      value
    (cond ((stringp value) :colored-line)
          ((and (listp value) (plist-member value :color))
           (plist-put (copy-tree value) :color :palette-line-color))
          (t value))))

(defun complementary-light-test--same-attribute-p (old new)
  "Compare OLD and NEW snapshot rows, ignoring embedded line color only."
  (let ((attribute (car old)))
    (and (equal (complementary-light-test--attribute-shape
                 attribute (nth 1 old))
                (complementary-light-test--attribute-shape
                 attribute (nth 1 new)))
         (equal (complementary-light-test--attribute-shape
                 attribute (nth 2 old))
                (complementary-light-test--attribute-shape
                 attribute (nth 2 new))))))

(ert-deftest complementary-light-preserves-non-color-attributes ()
  (let* ((faces (face-list))
         (before (complementary-light-test--attribute-snapshot faces)))
    (unwind-protect
        (progn
          (load-theme 'complementary-light t)
          (let ((after (complementary-light-test--attribute-snapshot faces))
                unexpected)
            (dolist (old before)
              (let ((new (assq (car old) after)))
                (cl-mapc
                 (lambda (old-attribute new-attribute)
                   (unless (or (complementary-light-test--same-attribute-p
                                old-attribute new-attribute)
                               (complementary-light-test--allowed-attribute-p
                                (car old) (car old-attribute)))
                     (push (list :face (car old)
                                 :attribute (car old-attribute)
                                 :before-direct (nth 1 old-attribute)
                                 :after-direct (nth 1 new-attribute)
                                 :before-effective (nth 2 old-attribute)
                                 :after-effective (nth 2 new-attribute)
                                 :reason nil)
                           unexpected)))
                 (cdr old) (cdr new))))
            (should (or (null unexpected)
                        (ert-fail (format "Unexpected attribute differences: %S"
                                          unexpected))))))
      (when (custom-theme-enabled-p 'complementary-light)
        (disable-theme 'complementary-light)))))

(ert-deftest complementary-light-non-color-allowlist-is-empty ()
  (should-not complementary-light-non-color-attribute-allowlist))

(ert-deftest complementary-light-preserves-diff-non-color-attributes-exactly ()
  (require 'diff-mode)
  (let* ((faces '(diff-added diff-removed diff-changed diff-refine-added
                  diff-refine-removed diff-refine-changed diff-header
                  diff-file-header diff-hunk-header))
         (before (complementary-light-test--attribute-snapshot faces)))
    (unwind-protect
        (progn
          (load-theme 'complementary-light t)
          (should
           (equal before
                  (complementary-light-test--attribute-snapshot faces))))
      (when (custom-theme-enabled-p 'complementary-light)
        (disable-theme 'complementary-light)))))

(ert-deftest complementary-light-preserves-gnus-non-color-attributes-exactly ()
  (require 'gnus)
  (require 'gnus-art)
  (require 'gnus-cite)
  (require 'gnus-srvr)
  (let* ((faces '(gnus-cite-1 gnus-emphasis-highlight-words
                  gnus-group-mail-1 gnus-group-mail-1-empty
                  gnus-header-content gnus-header-subject
                  gnus-server-cloud-host gnus-summary-cancelled
                  gnus-summary-high-read gnus-summary-low-read
                  gnus-summary-normal-read gnus-summary-selected))
         (before (complementary-light-test--attribute-snapshot faces)))
    (unwind-protect
        (progn
          (load-theme 'complementary-light t)
          (should
           (equal before
                  (complementary-light-test--attribute-snapshot faces))))
      (when (custom-theme-enabled-p 'complementary-light)
        (disable-theme 'complementary-light)))))

(provide 'complementary-light-attributes-test)
;;; complementary-light-attributes-test.el ends here
