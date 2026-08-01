;;; complementary-light-contrast-test.el --- WCAG-inspired tests  -*- lexical-binding: t; -*-

(require 'complementary-light-test-helper)

(defun complementary-light-test--check-pair (name secondary pair)
  "Assert contrast PAIR for NAME and SECONDARY with a detailed failure."
  (let* ((fg-token (nth 0 pair))
         (bg-token (nth 1 pair))
         (required (nth 2 pair))
         (fg (complementary-light-token fg-token name secondary))
         (bg (complementary-light-token bg-token name secondary))
         (ratio (complementary-light-contrast-ratio fg bg)))
    (should
     (or (>= ratio required)
         (ert-fail
          (format (concat "color=%s token=%s/%s foreground=%s background=%s "
                          "ratio=%.3f required=%.1f")
                  name fg-token bg-token fg bg ratio required))))))

(ert-deftest complementary-light-all-palette-contrast-pairs-pass ()
  (dolist (name complementary-light-color-names)
    (dolist (secondary complementary-light-color-names)
      (dolist (pair complementary-light-contrast-pairs)
        (complementary-light-test--check-pair name secondary pair))
      (dolist (scenario complementary-light-overlap-scenarios)
        (complementary-light-test--check-pair
         name secondary (cdr scenario))))))

(ert-deftest complementary-light-distant-foreground-passes ()
  (dolist (name complementary-light-color-names)
    (let* ((palette (complementary-light-palette name))
           (distant (plist-get palette :distant-foreground)))
      (dolist (background '(:strong :medium :subtle))
        ;; Strong uses on-strong because distant foreground is for pale
        ;; overlays; medium and subtle validate the declared distant token.
        (let ((foreground (if (eq background :strong)
                              (plist-get palette :on-strong) distant))
              (bg (plist-get palette background)))
          (should (>= (complementary-light-contrast-ratio foreground bg)
                      4.5)))))))

(defun complementary-light-test--check-minimum
    (label foreground backgrounds required)
  "Assert LABEL reaches REQUIRED against its hardest BACKGROUNDS pair."
  (let ((ratio (apply #'min
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

(ert-deftest complementary-light-owned-colors-meet-aa-thresholds ()
  (let* ((neutral (lambda (token)
                    (complementary-light-token token 'yellow 'purple)))
         (background (funcall neutral 'background))
         (surface-raised (funcall neutral 'surface-raised))
         (surface-sunken (funcall neutral 'surface-sunken))
         (accent-surfaces
          (cl-loop for name in complementary-light-color-names
                   append (let ((palette (complementary-light-palette name)))
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
      (complementary-light-test--check-minimum
       (symbol-name (car entry))
       (funcall neutral (car entry))
       (cadr entry)
       (nth 2 entry))))
  (dolist (name complementary-light-color-names)
    (let* ((palette (complementary-light-palette name))
           (neutral (lambda (token)
                      (complementary-light-token token name
                                                 (complementary-light-paired-accent
                                                  name))))
           (text-backgrounds
            (append
             (list (funcall neutral 'background)
                   (funcall neutral 'surface-raised)
                   (funcall neutral 'surface-sunken))
             (cl-loop for background-name in complementary-light-color-names
                      append
                      (let ((background-palette
                             (complementary-light-palette background-name)))
                        (list (plist-get background-palette :medium)
                              (plist-get background-palette :subtle)))))))
      (complementary-light-test--check-minimum
       (format "%s/text" name) (plist-get palette :text)
       text-backgrounds 4.5)
      (dolist (entry '((:on-strong :strong 4.5)
                       (:on-medium :medium 4.5)
                       (:on-subtle :subtle 4.5)
                       (:border nil 3.0)
                       (:focus nil 3.0)))
        (complementary-light-test--check-minimum
         (format "%s/%s" name (car entry))
         (plist-get palette (car entry))
         (list (if (cadr entry)
                   (plist-get palette (cadr entry))
                 (funcall neutral 'background)))
         (nth 2 entry)))
      (complementary-light-test--check-minimum
       (format "%s/distant-foreground" name)
       (plist-get palette :distant-foreground)
       (list (plist-get palette :medium)
             (plist-get palette :subtle))
       4.5))))

(provide 'complementary-light-contrast-test)
;;; complementary-light-contrast-test.el ends here
