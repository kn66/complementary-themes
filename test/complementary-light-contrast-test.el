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

(ert-deftest complementary-light-cursor-remains-visible-on-common-surfaces ()
  (dolist (primary complementary-light-color-names)
    (dolist (secondary complementary-light-color-names)
      (let ((cursor (complementary-light-token 'cursor primary secondary)))
        (dolist (background-token
                 complementary-light-cursor-background-tokens)
          (let* ((background
                  (complementary-light-token
                   background-token primary secondary))
                 (ratio
                  (complementary-light-contrast-ratio cursor background)))
            (should
             (or (>= ratio complementary-light-non-text-contrast-target)
                 (ert-fail
                  (format (concat "cursor=%s/%s surface=%s ratio=%.4f "
                                  "required>=%.2f")
                          primary secondary background-token ratio
                          complementary-light-non-text-contrast-target))))))))))

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
                      complementary-light-accent-text-contrast-target)))))))

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

(ert-deftest complementary-light-owned-colors-meet-declared-thresholds ()
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
             `((foreground ,content-surfaces ,complementary-light-text-contrast-target)
               (foreground-muted ,content-surfaces ,complementary-light-text-contrast-target)
               (distant-foreground ,accent-surfaces ,complementary-light-text-contrast-target)
               (foreground-secondary (,surface-raised ,surface-sunken) ,complementary-light-text-contrast-target)
               (foreground-faint (,background) ,complementary-light-text-contrast-target)
               (comment-foreground (,background) ,complementary-light-comment-text-contrast-target)
               (inactive-foreground
                (,(funcall neutral 'inactive-background)) ,complementary-light-text-contrast-target)
               (border (,background) ,complementary-light-non-text-contrast-target)
               (border-strong (,surface-sunken) ,complementary-light-non-text-contrast-target)
               (divider (,background) ,complementary-light-non-text-contrast-target)))
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
       text-backgrounds complementary-light-accent-text-contrast-target)
      (dolist (entry `((:on-strong :strong ,complementary-light-accent-text-contrast-target)
                       (:on-medium :medium ,complementary-light-accent-text-contrast-target)
                       (:on-subtle :subtle ,complementary-light-accent-text-contrast-target)
                       (:border nil ,complementary-light-accent-non-text-contrast-target)
                       (:focus nil ,complementary-light-accent-non-text-contrast-target)))
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
       complementary-light-accent-text-contrast-target))))

(provide 'complementary-light-contrast-test)
;;; complementary-light-contrast-test.el ends here
