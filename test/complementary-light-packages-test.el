;;; complementary-light-packages-test.el --- Package face tests  -*- lexical-binding: t; -*-

(require 'complementary-light-test-helper)

(ert-deftest complementary-light-init-packages-are-declared-supported ()
  (dolist (package '(avy consult corfu ddskk denote diff-hl eglot embark
                     magit marginalia tempel treesit-fold vundo wgrep which-key))
    (should (memq package complementary-light-supported-packages))))

(ert-deftest complementary-light-expanded-packages-are-declared-supported ()
  (dolist (package '(company flycheck gptel helm ivy markdown-mode vertico))
    (should (memq package complementary-light-supported-packages))))

(ert-deftest complementary-light-expanded-package-rule-counts-match-audit ()
  (dolist (entry '((company . 8)
                   (flycheck . 6)
                   (gptel . 4)
                   (helm . 63)
                   (ivy . 9)
                   (markdown-mode . 1)
                   (vertico . 2)))
    (should
     (= (cdr entry)
        (cl-count (car entry) complementary-light-package-face-rules
                  :key (lambda (rule)
                         (plist-get (cdr rule) :package)))))))

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
                           ((class color) (min-colors 256))
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
  (dolist (face '(avy-lead-face company-tooltip corfu-current diff-hl-insert
                  flycheck-error gptel-response-highlight helm-selection
                  ivy-current-match magit-section-heading magit-diff-added
                  markdown-highlighting-face skk-henkan-face-default
                  tempel-field transient-enabled-suffix vertico-quick1
                  vundo-highlight wgrep-face))
    (should (complementary-light-package-face-rule face))
    (should (assq face (complementary-light-build-package-face-specs
                        'yellow 'purple)))))

(ert-deftest complementary-light-expanded-package-semantics-are-stable ()
  (dolist (expectation
           '((company-tooltip :background surface-raised)
             (flycheck-annotate-error-background :background primary-subtle)
             (gptel-rewrite-highlight-face :background secondary-subtle)
             (helm-selection :background primary-medium)
             (ivy-confirm-face :foreground secondary-text)
             (markdown-highlighting-face :background primary-medium)
             (vertico-quick2 :background secondary-strong)))
    (let ((rule (complementary-light-package-face-rule (car expectation))))
      (should rule)
      (should (eq (plist-get (cdr rule) (nth 1 expectation))
                  (nth 2 expectation))))))

(provide 'complementary-light-packages-test)
;;; complementary-light-packages-test.el ends here
