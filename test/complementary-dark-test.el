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

(ert-deftest complementary-dark-all-palette-contrast-pairs-pass ()
  (dolist (primary complementary-light-color-names)
    (dolist (secondary complementary-light-color-names)
      (dolist (pair complementary-light-contrast-pairs)
        (complementary-dark-test--check-pair primary secondary pair))
      (dolist (scenario complementary-light-overlap-scenarios)
        (complementary-dark-test--check-pair
         primary secondary (cdr scenario))))))

(ert-deftest complementary-dark-owned-colors-meet-aa-thresholds ()
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
             `((foreground ,content-surfaces 4.5)
               (foreground-muted ,content-surfaces 4.5)
               (distant-foreground ,accent-surfaces 4.5)
               (foreground-secondary (,surface-raised ,surface-sunken) 4.5)
               (foreground-faint (,background) 4.5)
               (inactive-foreground
                (,(funcall neutral 'inactive-background)) 4.5)
               (border (,background) 3.0)
               (border-strong (,surface-sunken) 3.0)
               (divider (,background) 3.0)))
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
         text-backgrounds 4.5)
        (dolist (entry '((:on-strong :strong 4.5)
                         (:on-medium :medium 4.5)
                         (:on-subtle :subtle 4.5)
                         (:border nil 3.0)
                         (:focus nil 3.0)))
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
         4.5)))))

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
