;;; complementary-light-terminal-test.el --- Display fallback tests  -*- lexical-binding: t; -*-

(require 'complementary-light-test-helper)
(require 'complementary-dark)

(ert-deftest complementary-light-face-specs-have-display-fallbacks ()
  (dolist (spec (complementary-light-build-face-specs 'yellow 'purple))
    (let ((displays (cadr spec)))
      (should (cl-find-if
               (lambda (entry) (equal (car entry)
                                      '((class color) (min-colors 257))))
               displays))
      (should (cl-find-if
               (lambda (entry) (equal (car entry)
                                      '((class color) (min-colors 256))))
               displays))
      (should (cl-find-if
               (lambda (entry) (equal (car entry)
                                      '((class color) (min-colors 16))))
               displays))
      (should (cl-find-if
               (lambda (entry) (equal (car entry) '((class mono))))
               displays)))))

(defun complementary-light-test--assert-terminal-pairs (specs label)
  "Assert explicit xterm-256 text pairs in SPECS pass, reporting LABEL."
  (dolist (spec specs)
    (dolist (clause (cadr spec))
      (when (member '(min-colors 256) (car clause))
        (when-let* ((attributes (cadr clause))
                    (foreground (plist-get attributes :foreground))
                    (background (plist-get attributes :background)))
          (let* ((terminal-foreground
                  (complementary-light-xterm-256-color foreground))
                 (terminal-background
                  (complementary-light-xterm-256-color background))
                 (ratio (complementary-light-contrast-ratio
                         terminal-foreground terminal-background)))
            (should
             (or (>= ratio 4.5)
                 (ert-fail
                  (format (concat "%s face=%s foreground=%s->%s "
                                  "background=%s->%s ratio=%.3f")
                          label (car spec) foreground terminal-foreground
                          background terminal-background ratio))))))))))

(ert-deftest complementary-light-xterm-256-quantization-matches-emacs ()
  ;; Values observed from `tty-color-values' on Emacs 30 xterm-256color.
  (should (equal (complementary-light-xterm-256-color "#c5a336")
                 "#d7af5f"))
  (should (equal (complementary-light-xterm-256-color "#453c1c")
                 "#5f5f00")))

(ert-deftest complementary-light-xterm-256-explicit-pairs-pass ()
  (dolist (primary complementary-light-color-names)
    (dolist (secondary complementary-light-color-names)
      (complementary-light-test--assert-terminal-pairs
       (complementary-light-build-face-specs primary secondary)
       (format "light/%s/%s" primary secondary))
      (complementary-dark--with-palette
        (complementary-light-test--assert-terminal-pairs
         (complementary-light-build-face-specs primary secondary)
         (format "dark/%s/%s" primary secondary))))))

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
