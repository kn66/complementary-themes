;;; complementary-dark-test.el --- Dark theme and palette tests  -*- lexical-binding: t; -*-

(require 'complementary-light-test-helper)
(require 'complementary-dark)

(defun complementary-dark-test--check-pair (primary secondary pair)
  "Assert dark contrast PAIR for PRIMARY and SECONDARY."
  (let* ((foreground-token (nth 0 pair))
         (background-token (nth 1 pair))
         (required (nth 2 pair))
         (foreground
          (complementary-dark-token foreground-token primary secondary))
         (background
          (complementary-dark-token background-token primary secondary))
         (ratio (complementary-light-contrast-ratio foreground background)))
    (should
     (or (>= ratio required)
         (ert-fail
          (format (concat "dark=%s/%s token=%s/%s foreground=%s "
                          "background=%s ratio=%.4f required=%.1f")
                  primary secondary foreground-token background-token
                  foreground background ratio required))))))

(defun complementary-dark-test--check-minimum
    (label foreground backgrounds required)
  "Assert LABEL reaches REQUIRED against its hardest BACKGROUNDS pair."
  (let ((ratio
         (apply #'min
                (mapcar (lambda (background)
                          (complementary-light-contrast-ratio
                           foreground background))
                        backgrounds))))
    (should
     (or (>= ratio required)
         (ert-fail
          (format (concat "%s foreground=%s minimum-ratio=%.4f "
                          "required>=%.2f")
                  label foreground ratio required))))))

(ert-deftest complementary-dark-palettes-are-complete ()
  (should-not (complementary-dark-validate-palettes))
  (should (= (length complementary-light-color-names)
             (length complementary-dark-palettes))))

(ert-deftest complementary-dark-palettes-share-semantic-tones ()
  (should (= 10 (length (delete-dups
                         (mapcar #'cdr complementary-dark-neutral-palette)))))
  (dolist (entry complementary-dark-palettes)
    (let ((palette (cdr entry)))
      (should (= 6 (length
                    (delete-dups
                     (cl-loop for (_ value) on palette by #'cddr
                              collect value)))))
      (should (equal (plist-get palette :on-strong)
                     (alist-get 'cursor complementary-dark-neutral-palette)))
      (dolist (token '(:on-medium :on-subtle :distant-foreground))
        (should (equal (plist-get palette token)
                       (plist-get palette :text))))
      (should (equal (plist-get palette :focus)
                     (plist-get palette :border))))))

(ert-deftest complementary-dark-body-text-outranks-muted-and-accent-text ()
  (let* ((background (alist-get 'background complementary-dark-neutral-palette))
         (foreground (alist-get 'foreground complementary-dark-neutral-palette))
         (foreground-ratio
          (complementary-light-contrast-ratio foreground background)))
    (dolist (token '(foreground-muted distant-foreground))
      (should
       (> foreground-ratio
          (complementary-light-contrast-ratio
           (alist-get token complementary-dark-neutral-palette)
           background))))
    (dolist (entry complementary-dark-palettes)
      (should
       (> foreground-ratio
          (complementary-light-contrast-ratio
           (plist-get (cdr entry) :text) background))))))

(ert-deftest complementary-dark-medium-surfaces-remain-chromatic-by-polarity ()
  (dolist (name complementary-light-color-names)
    (let ((light-channels
           (complementary-light--hex-rgb
            (plist-get (complementary-light-palette name) :medium)))
          (dark-channels
           (complementary-light--hex-rgb
            (plist-get (complementary-dark-palette name) :medium))))
      (dolist (channels (list light-channels dark-channels))
        (let ((hsl
               (apply #'color-rgb-to-hsl
                      (mapcar (lambda (channel) (/ channel 255.0))
                              channels))))
          (should (>= (nth 1 hsl) 0.65))))
      (should (> (complementary-light-relative-luminance
                  (plist-get (complementary-light-palette name) :medium))
                 0.75))
      (should (< (complementary-light-relative-luminance
                  (plist-get (complementary-dark-palette name) :medium))
                 0.15)))))

(ert-deftest complementary-dark-all-palette-contrast-pairs-pass ()
  (dolist (primary complementary-light-color-names)
    (dolist (secondary complementary-light-color-names)
      (dolist (pair complementary-dark-contrast-pairs)
        (complementary-dark-test--check-pair primary secondary pair))
      (dolist (scenario complementary-dark-overlap-scenarios)
        (complementary-dark-test--check-pair
         primary secondary (cdr scenario))))))

(ert-deftest complementary-dark-cursor-remains-visible-on-common-surfaces ()
  (dolist (primary complementary-light-color-names)
    (dolist (secondary complementary-light-color-names)
      (let ((cursor (complementary-dark-token 'cursor primary secondary)))
        (dolist (background-token
                 complementary-light-cursor-background-tokens)
          (let* ((background
                  (complementary-dark-token
                   background-token primary secondary))
                 (ratio
                  (complementary-light-contrast-ratio cursor background)))
            (should
             (or (>= ratio complementary-light-non-text-contrast-target)
                 (ert-fail
                  (format (concat "dark cursor=%s/%s surface=%s ratio=%.4f "
                                  "required>=%.2f")
                          primary secondary background-token ratio
                          complementary-light-non-text-contrast-target))))))))))

(ert-deftest complementary-dark-state-tokens-use-cursor-safe-surfaces ()
  (dolist (primary complementary-light-color-names)
    (let* ((secondary (complementary-light-paired-accent primary))
           (state (complementary-dark-token
                   'primary-state primary secondary))
           (on-state (complementary-dark-token
                      'primary-on-state primary secondary)))
      (should (equal state
                     (plist-get (complementary-dark-palette primary) :border)))
      (should (equal on-state
                     (complementary-dark-token 'cursor primary secondary)))
      (should
       (>= (complementary-light-contrast-ratio on-state state)
           complementary-light-text-contrast-target)))))

(ert-deftest complementary-dark-primary-and-secondary-must-be-distinct ()
  (let ((complementary-dark-primary-color 'yellow)
        (complementary-dark-secondary-color 'purple))
    (should-error (complementary-dark--valid-secondary 'purple nil)
                  :type 'user-error)
    (should-error (complementary-dark-set-primary-color 'purple)
                  :type 'user-error)
    (should-error (complementary-dark-set-secondary-color 'yellow)
                  :type 'user-error)))

(ert-deftest complementary-dark-owned-colors-meet-original-thresholds ()
  (let* ((neutral (lambda (token)
                    (complementary-dark-token token 'yellow 'purple)))
         (background (funcall neutral 'background))
         (surface-raised (funcall neutral 'surface-raised))
         (surface-sunken (funcall neutral 'surface-sunken))
         (accent-surfaces
          (cl-loop for name in complementary-light-color-names
                   append (let ((palette (complementary-dark-palette name)))
                            (list (plist-get palette :medium)
                                  (plist-get palette :subtle)))))
         (content-surfaces
          (append (list background surface-raised surface-sunken)
                  accent-surfaces)))
    (dolist (entry
             `((foreground ,content-surfaces ,complementary-light-text-contrast-target)
               (foreground-muted ,content-surfaces ,complementary-light-text-contrast-target)
               (distant-foreground ,accent-surfaces ,complementary-light-text-contrast-target)
               (foreground-secondary (,surface-raised ,surface-sunken) ,complementary-light-text-contrast-target)
               (foreground-faint (,background) ,complementary-light-text-contrast-target)
               (comment-foreground (,background) ,complementary-light-text-contrast-target)
               (inactive-foreground
                (,(funcall neutral 'inactive-background)) ,complementary-light-text-contrast-target)
               (border (,background) ,complementary-light-non-text-contrast-target)
               (border-strong (,surface-sunken) ,complementary-light-non-text-contrast-target)
               (divider (,background) ,complementary-light-non-text-contrast-target)))
      (complementary-dark-test--check-minimum
       (format "dark/%s" (car entry))
       (funcall neutral (car entry))
       (cadr entry)
       (nth 2 entry)))
    (dolist (name complementary-light-color-names)
      (let* ((palette (complementary-dark-palette name))
             (text-backgrounds content-surfaces))
        (complementary-dark-test--check-minimum
         (format "dark/%s/text" name) (plist-get palette :text)
         text-backgrounds complementary-light-text-contrast-target)
        (dolist (entry `((:on-strong :strong ,complementary-light-text-contrast-target)
                         (:on-medium :medium ,complementary-light-text-contrast-target)
                         (:on-subtle :subtle ,complementary-light-text-contrast-target)
                         (:border nil ,complementary-light-non-text-contrast-target)
                         (:focus nil ,complementary-light-non-text-contrast-target)))
          (complementary-dark-test--check-minimum
           (format "dark/%s/%s" name (car entry))
           (plist-get palette (car entry))
           (list (if (cadr entry)
                     (plist-get palette (cadr entry))
                   background))
           (nth 2 entry)))
        (complementary-dark-test--check-minimum
         (format "dark/%s/distant-foreground" name)
         (plist-get palette :distant-foreground)
         (list (plist-get palette :medium)
               (plist-get palette :subtle))
         complementary-light-text-contrast-target)))))

(ert-deftest complementary-dark-load-refresh-disable-repeat ()
  (unwind-protect
      (progn
        (load-theme 'complementary-dark t)
        (should (custom-theme-enabled-p 'complementary-dark))
        (let ((order (copy-sequence custom-enabled-themes))
              (settings-count
               (length (get 'complementary-dark 'theme-settings))))
          (complementary-dark-refresh)
          (complementary-dark-refresh)
          (should (equal order custom-enabled-themes))
          (should (= settings-count
                     (length (get 'complementary-dark 'theme-settings)))))
        (disable-theme 'complementary-dark)
        (should-not (custom-theme-enabled-p 'complementary-dark))
        (load-theme 'complementary-dark t)
        (should (= 1 (cl-count 'complementary-dark custom-enabled-themes))))
    (when (custom-theme-enabled-p 'complementary-dark)
      (disable-theme 'complementary-dark))))

(ert-deftest complementary-dark-and-light-settings-are-independent ()
  (let ((light-primary complementary-light-primary-color)
        (dark-primary complementary-dark-primary-color))
    (unwind-protect
        (progn
          (complementary-light-set-primary-color 'blue)
          (complementary-dark-set-primary-color 'green)
          (should (eq complementary-light-primary-color 'blue))
          (should (eq complementary-dark-primary-color 'green)))
      (setq complementary-light-primary-color light-primary
            complementary-dark-primary-color dark-primary))))

(ert-deftest complementary-dark-records-its-deferred-package-palette ()
  (complementary-dark--register-theme nil)
  (let ((configuration
         (alist-get 'complementary-dark
                    complementary-light--package-theme-registrations)))
    (should configuration)
    (should (eq (plist-get configuration :neutral-palette)
                complementary-dark-neutral-palette))
    (should (eq (plist-get configuration :accent-palettes)
                complementary-dark-palettes))))

(provide 'complementary-dark-test)
;;; complementary-dark-test.el ends here
