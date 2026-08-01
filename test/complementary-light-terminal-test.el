;;; complementary-light-terminal-test.el --- Display fallback tests  -*- lexical-binding: t; -*-

(require 'complementary-light-test-helper)

(ert-deftest complementary-light-face-specs-have-display-fallbacks ()
  (dolist (spec (complementary-light-build-face-specs 'yellow 'purple))
    (let ((displays (cadr spec)))
      (should (cl-find-if
               (lambda (entry) (equal (car entry)
                                      '((class color) (min-colors 257))))
               displays))
      (should (cl-find-if
               (lambda (entry) (equal (car entry)
                                      '((class color) (min-colors 16))))
               displays))
      (should (cl-find-if
               (lambda (entry) (equal (car entry) '((class mono))))
               displays)))))

(ert-deftest complementary-light-does-not-add-diff-non-color-attributes ()
  (let ((specs (complementary-light-build-face-specs 'yellow 'purple)))
    (dolist (check '((diff-added :weight)
                     (diff-removed :strike-through)
                     (diff-changed :underline)))
      (let ((clauses (cadr (assq (car check) specs)))
            (attribute (cadr check)))
        (should-not
         (cl-some (lambda (clause)
                    (plist-member (cadr clause) attribute))
                  clauses))))))

(ert-deftest complementary-light-backquoted-defface-specs-are-normalized ()
  (let ((normalized (complementary-light--default-face-spec 'org-block)))
    (dolist (clause normalized)
      (let ((display (car clause)))
        (should (or (eq display t)
                    (and (listp display)
                         (cl-every #'consp display))))))
    ;; This is the same selection path that failed on a graphical frame.
    (should (condition-case nil
                (progn (face-spec-choose normalized nil) t)
              (error nil)))))

(ert-deftest complementary-light-display-clauses-keep-color-topology ()
  (let* ((specs (complementary-light-build-face-specs 'yellow 'purple))
         (added (cadr (assq 'diff-added specs))))
    (should added)
    (dolist (clause added)
      (let ((attributes (cadr clause))
            (condition (car clause)))
        ;; The true-color/light built-in clause uses a background only.
        (when (and (member '((class color) (min-colors 257)) condition)
                   (member '(background light) condition))
          (should (plist-member attributes :background))
          (should-not (plist-member attributes :foreground)))))))

(provide 'complementary-light-terminal-test)
;;; complementary-light-terminal-test.el ends here
