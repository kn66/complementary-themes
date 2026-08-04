;;; complementary-light-palette-test.el --- Palette integrity tests  -*- lexical-binding: t; -*-

(require 'complementary-light-test-helper)

(ert-deftest complementary-light-palettes-are-complete ()
  (should-not (complementary-light-validate-palettes))
  (should (= (length complementary-light-color-names)
             (length complementary-light-palettes))))

(ert-deftest complementary-light-palettes-share-semantic-tones ()
  (should (= 11 (length (delete-dups
                         (mapcar #'cdr complementary-light-neutral-palette)))))
  (dolist (entry complementary-light-palettes)
    (let ((palette (cdr entry)))
      (should (= 6 (length
                    (delete-dups
                     (cl-loop for (_ value) on palette by #'cddr
                              collect value)))))
      (should (equal (plist-get palette :on-strong)
                     (alist-get 'background complementary-light-neutral-palette)))
      (dolist (token '(:on-medium :on-subtle :distant-foreground))
        (should (equal (plist-get palette token)
                       (plist-get palette :text))))
      (should (equal (plist-get palette :focus)
                     (plist-get palette :border))))))

(ert-deftest complementary-light-body-text-retains-hierarchy-over-accents ()
  (let* ((background
          (alist-get 'background complementary-light-neutral-palette))
         (foreground
          (alist-get 'foreground complementary-light-neutral-palette))
         (foreground-ratio
          (complementary-light-contrast-ratio foreground background)))
    (dolist (token '(foreground-secondary foreground-muted
                     inactive-foreground distant-foreground))
      (should
       (> foreground-ratio
          (complementary-light-contrast-ratio
           (alist-get token complementary-light-neutral-palette)
           background))))
    (dolist (entry complementary-light-palettes)
      (should
       (> foreground-ratio
          (complementary-light-contrast-ratio
           (plist-get (cdr entry) :text) background))))))

(ert-deftest complementary-light-accents-use-emergency-safety-floors ()
  (should (< complementary-light-accent-text-contrast-target
             complementary-light-wcag-text-contrast))
  (should (= complementary-light-accent-text-contrast-target 3.0))
  (should (= complementary-light-accent-non-text-contrast-target
             complementary-light-wcag-non-text-contrast))
  (should (< complementary-light-accent-non-text-contrast-target
             complementary-light-non-text-contrast-target)))

(ert-deftest complementary-light-accents-prioritize-chroma-over-uniform-ratios ()
  (let ((background
         (alist-get 'background complementary-light-neutral-palette))
        ratios)
    (dolist (entry complementary-light-palettes)
      (let ((palette (cdr entry)))
        (push (complementary-light-contrast-ratio
               (plist-get palette :text) background)
              ratios)
        (dolist (token '(:text :strong :medium :subtle :border))
          (let* ((channels
                  (complementary-light--hex-rgb
                   (plist-get palette token)))
                 (hsl
                  (apply #'color-rgb-to-hsl
                         (mapcar (lambda (channel) (/ channel 255.0))
                                 channels))))
            (should (>= (nth 1 hsl) 0.65))))))
    ;; The palette keeps useful hue-specific lightness instead of equalizing
    ;; every accent to a narrow contrast band.
    (should (> (- (apply #'max ratios) (apply #'min ratios)) 2.0))))

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
