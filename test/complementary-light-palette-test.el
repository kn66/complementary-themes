;;; complementary-light-palette-test.el --- Palette integrity tests  -*- lexical-binding: t; -*-

(require 'complementary-light-test-helper)

(ert-deftest complementary-light-palettes-are-complete ()
  (should-not (complementary-light-validate-palettes))
  (should (= (length complementary-light-color-names)
             (length complementary-light-palettes))))

(ert-deftest complementary-light-accent-contrast-is-softer-than-neutral ()
  (should (< complementary-light-accent-text-contrast-target
             complementary-light-wcag-text-contrast))
  (should (< complementary-light-accent-non-text-contrast-target
             complementary-light-wcag-non-text-contrast))
  (should (< complementary-light-accent-text-contrast-target
             complementary-light-text-contrast-target))
  (should (< complementary-light-accent-non-text-contrast-target
             complementary-light-non-text-contrast-target)))

(ert-deftest complementary-light-comment-contrast-is-visibly-subordinate ()
  (let* ((background (complementary-light-token 'background 'yellow 'purple))
         (comment (complementary-light-token
                   'comment-foreground 'yellow 'purple))
         (foreground (complementary-light-token 'foreground 'yellow 'purple))
         (comment-ratio
          (complementary-light-contrast-ratio comment background)))
    (should (>= comment-ratio
                complementary-light-comment-text-contrast-target))
    (should (<= comment-ratio
                complementary-light-comment-text-contrast-maximum))
    (should (< comment-ratio
               (complementary-light-contrast-ratio foreground background)))))

(ert-deftest complementary-light-pairs-are-symmetric-and-distinct ()
  (dolist (name complementary-light-color-names)
    (let ((paired (complementary-light-paired-accent name)))
      (should-not (eq name paired))
      (should (eq name (complementary-light-paired-accent paired))))))

(ert-deftest complementary-light-unknown-colors-signal ()
  (should-error (complementary-light-palette 'ultraviolet) :type 'user-error)
  (should-error (complementary-light-resolve-secondary
                 'yellow 'ultraviolet nil) :type 'user-error))

(ert-deftest complementary-light-primary-and-secondary-must-be-distinct ()
  (should-error (complementary-light-resolve-secondary
                 'yellow 'yellow nil) :type 'user-error)
  (should (eq (complementary-light-resolve-secondary
               'yellow 'yellow t)
              'purple))
  (let ((complementary-light-primary-color 'yellow)
        (complementary-light-secondary-color 'purple))
    (should-error (complementary-light-set-primary-color 'purple)
                  :type 'user-error)
    (should-error (complementary-light-set-secondary-color 'yellow)
                  :type 'user-error)))

(ert-deftest complementary-light-region-uses-secondary-medium-surface ()
  (dolist (primary complementary-light-color-names)
    (let ((secondary (complementary-light-paired-accent primary)))
      (should
       (equal (complementary-light-token
               'region-background primary secondary)
              (plist-get (complementary-light-palette secondary) :medium))))))

(ert-deftest complementary-light-state-tokens-keep-cursor-contrast ()
  (dolist (primary complementary-light-color-names)
    (let ((secondary (complementary-light-paired-accent primary)))
      (should
       (equal (complementary-light-token 'primary-state primary secondary)
              (plist-get (complementary-light-palette primary) :strong)))
      (should
       (>= (complementary-light-contrast-ratio
            (complementary-light-token 'cursor primary secondary)
            (complementary-light-token 'primary-state primary secondary))
           complementary-light-non-text-contrast-target)))))

(ert-deftest complementary-light-face-files-contain-no-color-literals ()
  (dolist (file '("lisp/complementary-light-faces.el"
                  "lisp/complementary-light-packages.el"
                  "complementary-light-theme.el"
                  "complementary-light.el"
                  "complementary-dark-theme.el"
                  "complementary-dark.el"))
    (with-temp-buffer
      (insert-file-contents (expand-file-name file complementary-light-test-root))
      (goto-char (point-min))
      (should-not (re-search-forward "#[[:xdigit:]]\\{6\\}" nil t)))))

(provide 'complementary-light-palette-test)
;;; complementary-light-palette-test.el ends here
