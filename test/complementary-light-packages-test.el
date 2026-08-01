;;; complementary-light-packages-test.el --- Package face tests  -*- lexical-binding: t; -*-

(require 'complementary-light-test-helper)

(ert-deftest complementary-light-init-packages-are-declared-supported ()
  (dolist (package '(avy consult corfu ddskk denote diff-hl eglot embark
                     magit marginalia tempel treesit-fold vundo wgrep which-key))
    (should (memq package complementary-light-supported-packages))))

(ert-deftest complementary-light-package-rules-are-color-only-and-unique ()
  (let (seen)
    (dolist (rule complementary-light-package-face-rules)
      (should-not (memq (car rule) seen))
      (push (car rule) seen)
      (should (memq (plist-get (cdr rule) :package)
                    complementary-light-supported-packages))
      (let ((properties (cdr rule)))
        (while properties
          (should (memq (car properties)
                        '(:package :foreground :background
                          :distant-foreground)))
          (setq properties (cddr properties)))))))

(ert-deftest complementary-light-package-rules-use-registered-tokens ()
  (dolist (rule complementary-light-package-face-rules)
    (dolist (attribute '(:foreground :background :distant-foreground))
      (when-let ((token (plist-get (cdr rule) attribute)))
        (should (complementary-light-token token 'yellow 'purple))))))

(ert-deftest complementary-light-package-specs-have-display-fallbacks ()
  (dolist (spec (complementary-light-build-package-face-specs
                 'yellow 'purple))
    (let ((displays (mapcar #'car (cadr spec))))
      (dolist (selector '(((class color) (min-colors 257))
                           ((class color) (min-colors 16))
                           ((class mono))))
        (should (cl-find-if
                 (lambda (display)
                   (cl-every (lambda (condition)
                               (member condition display))
                             selector))
                 displays))))))

(ert-deftest complementary-light-package-specs-preserve-known-non-colors ()
  ;; Transient is part of the recorded Emacs 30 inventory, so its defface is
  ;; available even when the library itself is not loaded by the test process.
  (let ((clauses
         (cadr (assq 'transient-disabled-suffix
                     (complementary-light-build-package-face-specs
                      'yellow 'purple)))))
    (should (cl-some (lambda (clause)
                       (eq (plist-get (cadr clause) :weight) 'bold))
                     clauses))))

(ert-deftest complementary-light-critical-package-faces-are-themed ()
  (dolist (face '(avy-lead-face corfu-current diff-hl-insert
                  magit-section-heading magit-diff-added
                  skk-henkan-face-default tempel-field
                  transient-enabled-suffix vundo-highlight wgrep-face))
    (should (complementary-light-package-face-rule face))
    (should (assq face (complementary-light-build-package-face-specs
                        'yellow 'purple)))))

(provide 'complementary-light-packages-test)
;;; complementary-light-packages-test.el ends here
