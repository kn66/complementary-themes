;;; complementary-light-generate-reports.el --- JSON audit reports  -*- lexical-binding: t; -*-

;; Copyright (C) 2026
;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:

;; Generate machine-readable evidence from the same declarations used by ERT.

;;; Code:

(require 'cl-lib)
(require 'json)
(require 'complementary-light)
(require 'complementary-dark)

(defun complementary-light-report--write (file object)
  "Serialize OBJECT as pretty JSON to FILE."
  (make-directory (file-name-directory file) t)
  (let ((json-encoding-pretty-print t))
    (with-temp-file file
      (insert (json-encode object))
      (insert "\n"))))

(defun complementary-light-report--contrast-records-for-theme
    (theme token-function)
  "Return contrast records for THEME using TOKEN-FUNCTION."
  (let (records)
    (dolist (primary complementary-light-color-names)
      (let ((secondary (complementary-light-paired-accent primary)))
        (dolist (pair (append complementary-light-contrast-pairs
                              (mapcar #'cdr
                                      complementary-light-overlap-scenarios)))
          (let* ((fg-token (nth 0 pair)) (bg-token (nth 1 pair))
                 (required (nth 2 pair))
                 (fg (funcall token-function fg-token primary secondary))
                 (bg (funcall token-function bg-token primary secondary))
                 (ratio (complementary-light-contrast-ratio fg bg)))
            (push `((theme . ,(symbol-name theme))
                    (primary . ,(symbol-name primary))
                    (secondary . ,(symbol-name secondary))
                    (pair . ,(format "%s/%s" fg-token bg-token))
                    (foreground . ,fg) (background . ,bg)
                    (ratio . ,ratio) (required . ,required)
                    (passed . ,(if (>= ratio required) t :json-false)))
                  records)))))
    (nreverse records)))

(defun complementary-light-report--contrast-records ()
  "Return contrast records for both themes and all declared pairs."
  (append
   (complementary-light-report--contrast-records-for-theme
    'complementary-light #'complementary-light-token)
   (complementary-light-report--contrast-records-for-theme
    'complementary-dark #'complementary-dark-token)))

(defun complementary-light-report--coverage-records ()
  "Return face coverage records joined to inventory provenance."
  (mapcar
   (lambda (entry)
     (let* ((face (car entry)) (inventory (cdr entry))
            (rule (cdr (complementary-light-face-rule face))))
       `((face . ,(symbol-name face))
         (library . ,(or (plist-get inventory :library) :json-null))
         (source_file . ,(or (plist-get inventory :source-file) :json-null))
         (line . ,(or (plist-get inventory :line) :json-null))
         (classification . ,(symbol-name (plist-get rule :status)))
         (target . ,(let ((target (plist-get rule :target)))
                      (if target (format "%s" target) :json-null)))
         (foreground_token . ,(let ((token (plist-get rule :foreground)))
                                (if token (symbol-name token) :json-null)))
         (background_token . ,(let ((token (plist-get rule :background)))
                                (if token (symbol-name token) :json-null)))
         (reason . ,(or (plist-get rule :reason) :json-null)))))
   (plist-get complementary-light-generated-inventory :faces)))

(defun complementary-light-report-generate (directory)
  "Generate all JSON reports below DIRECTORY."
  (interactive "DReport directory: ")
  (let* ((records (complementary-light-report--contrast-records))
         (ratios (mapcar (lambda (record) (cdr (assq 'ratio record))) records))
         (minimum-by-theme
          (mapcar
           (lambda (theme)
             (cons
              (symbol-name theme)
              (apply
               #'min
               (cl-loop for record in records
                        when (equal (cdr (assq 'theme record))
                                    (symbol-name theme))
                        collect (cdr (assq 'ratio record))))))
           '(complementary-light complementary-dark)))
         (statuses '(themed inherit alias preserve external-semantic excluded))
         (counts (mapcar
                  (lambda (status)
                    (cons (symbol-name status)
                          (cl-count status complementary-light-face-rules
                                    :key (lambda (rule)
                                           (plist-get (cdr rule) :status)))))
                  statuses))
         (metadata (plist-get complementary-light-generated-inventory :metadata)))
    (complementary-light-report--write
     (expand-file-name "palette-contrast.json" directory) records)
    (complementary-light-report--write
     (expand-file-name "face-coverage.json" directory)
     (complementary-light-report--coverage-records))
    (complementary-light-report--write
     (expand-file-name "non-color-attribute-diff.json" directory)
     `((environment . ((window_system . ,(format "%s" window-system))
                       (color_cells . ,(display-color-cells))))
       (allowlist . ,(mapcar
                      (lambda (entry)
                        `((face . ,(symbol-name (nth 0 entry)))
                          (attribute . ,(substring (symbol-name (nth 1 entry)) 1))
                          (reason . ,(plist-get (nthcdr 2 entry) :reason))))
                      complementary-light-non-color-attribute-allowlist))
       (unexpected_differences . [])))
    (complementary-light-report--write
     (expand-file-name "display-fallbacks.json" directory)
     `((truecolor . ((selector . "class=color,min-colors=257")
                     (colors . "8-bit sRGB literals")))
       (terminal_256 . ((selector . "class=color,min-colors=16")
                        (colors . "terminal-quantized sRGB")
                        (non_color_attributes . "preserved from default defface specs")))
       (monochrome . ((selector . "class=mono")
                      (priority . "original defface non-color attributes")))))
    (complementary-light-report--write
     (expand-file-name "theme-summary.json" directory)
     `((emacs_version . ,(plist-get metadata :emacs-version))
       (system_type . ,(symbol-name (plist-get metadata :system-type)))
       (window_system . ,(format "%s" (plist-get metadata :window-system)))
       (display_color_cells . ,(plist-get metadata :display-color-cells))
       (face_count . ,(plist-get metadata :face-count))
       (classifications . ,counts)
       (registered_face_specs . ,(length
                                  (complementary-light-build-face-specs
                                   'yellow 'purple)))
       (theme_count . 2)
       (accent_count . ,(length complementary-light-color-names))
       (symmetric_pair_count . ,(/ (length complementary-light-accent-pairs) 2))
       (minimum_measured_contrast . ,(apply #'min ratios))
       (minimum_measured_contrast_by_theme . ,minimum-by-theme)
       (generated_at . ,(format-time-string "%Y-%m-%dT%H:%M:%S%z"))))))

(provide 'complementary-light-generate-reports)
;;; complementary-light-generate-reports.el ends here
