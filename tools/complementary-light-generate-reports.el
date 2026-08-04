;;; complementary-light-generate-reports.el --- JSON audit reports  -*- lexical-binding: t; -*-

;; Copyright (C) 2026
;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:

;; Generate machine-readable evidence from the same declarations used by ERT.

;;; Code:

(require 'cl-lib)
(require 'color)
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
    (theme token-function contrast-pairs overlap-scenarios)
  "Return contrast records for THEME using TOKEN-FUNCTION and its gates."
  (let (records)
    (dolist (primary complementary-light-color-names)
      (let ((secondary (complementary-light-paired-accent primary)))
        (dolist (pair (append contrast-pairs
                              (mapcar #'cdr
                                      overlap-scenarios)))
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
    'complementary-light #'complementary-light-token
    complementary-light-contrast-pairs complementary-light-overlap-scenarios)
   (complementary-light-report--contrast-records-for-theme
    'complementary-dark #'complementary-dark-token
    complementary-dark-contrast-pairs complementary-dark-overlap-scenarios)))

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

(defconst complementary-light-report--color-vision-matrices
  '((protanomaly 0.1
     ((0.856167 0.182038 -0.038205)
      (0.029342 0.955115 0.015544)
      (-0.002880 -0.001563 1.004443)))
    (protanomaly 0.2
     ((0.734766 0.334872 -0.069637)
      (0.051840 0.919198 0.028963)
      (-0.004928 -0.004209 1.009137)))
    (protanomaly 0.3
     ((0.630323 0.465641 -0.095964)
      (0.069181 0.890046 0.040773)
      (-0.006308 -0.007724 1.014032)))
    (protanomaly 0.4
     ((0.539009 0.579343 -0.118352)
      (0.082546 0.866121 0.051332)
      (-0.007136 -0.011959 1.019095)))
    (protanomaly 0.5
     ((0.458064 0.679578 -0.137642)
      (0.092785 0.846313 0.060902)
      (-0.007494 -0.016807 1.024301)))
    (protanomaly 0.6
     ((0.385450 0.769005 -0.154455)
      (0.100526 0.829802 0.069673)
      (-0.007442 -0.022190 1.029632)))
    (protanomaly 0.7
     ((0.319627 0.849633 -0.169261)
      (0.106241 0.815969 0.077790)
      (-0.007025 -0.028051 1.035076)))
    (protanomaly 0.8
     ((0.259411 0.923008 -0.182420)
      (0.110296 0.804340 0.085364)
      (-0.006276 -0.034346 1.040622)))
    (protanomaly 0.9
     ((0.203876 0.990338 -0.194214)
      (0.112975 0.794542 0.092483)
      (-0.005222 -0.041043 1.046265)))
    (protanomaly 1.0
     ((0.152286 1.052583 -0.204868)
      (0.114503 0.786281 0.099216)
      (-0.003882 -0.048116 1.051998)))
    (deuteranomaly 0.1
     ((0.866435 0.177704 -0.044139)
      (0.049567 0.939063 0.011370)
      (-0.003453 0.007233 0.996220)))
    (deuteranomaly 0.2
     ((0.760729 0.319078 -0.079807)
      (0.090568 0.889315 0.020117)
      (-0.006027 0.013325 0.992702)))
    (deuteranomaly 0.3
     ((0.675425 0.433850 -0.109275)
      (0.125303 0.847755 0.026942)
      (-0.007950 0.018572 0.989378)))
    (deuteranomaly 0.4
     ((0.605511 0.528560 -0.134071)
      (0.155318 0.812366 0.032316)
      (-0.009376 0.023176 0.986200)))
    (deuteranomaly 0.5
     ((0.547494 0.607765 -0.155259)
      (0.181692 0.781742 0.036566)
      (-0.010410 0.027275 0.983136)))
    (deuteranomaly 0.6
     ((0.498864 0.674741 -0.173604)
      (0.205199 0.754872 0.039929)
      (-0.011131 0.030969 0.980162)))
    (deuteranomaly 0.7
     ((0.457771 0.731899 -0.189670)
      (0.226409 0.731012 0.042579)
      (-0.011595 0.034333 0.977261)))
    (deuteranomaly 0.8
     ((0.422823 0.781057 -0.203881)
      (0.245752 0.709602 0.044646)
      (-0.011843 0.037423 0.974421)))
    (deuteranomaly 0.9
     ((0.392952 0.823610 -0.216562)
      (0.263559 0.690210 0.046232)
      (-0.011910 0.040281 0.971630)))
    (deuteranomaly 1.0
     ((0.367322 0.860646 -0.227968)
      (0.280085 0.672501 0.047413)
      (-0.011820 0.042940 0.968881)))
    (tritanomaly 0.1
     ((0.926670 0.092514 -0.019184)
      (0.021191 0.964503 0.014306)
      (0.008437 0.054813 0.936750)))
    (tritanomaly 0.2
     ((0.895720 0.133330 -0.029050)
      (0.029997 0.945400 0.024603)
      (0.013027 0.104707 0.882266)))
    (tritanomaly 0.3
     ((0.905871 0.127791 -0.033662)
      (0.026856 0.941251 0.031893)
      (0.013410 0.148296 0.838294)))
    (tritanomaly 0.4
     ((0.948035 0.089490 -0.037526)
      (0.014364 0.946792 0.038844)
      (0.010853 0.193991 0.795156)))
    (tritanomaly 0.5
     ((1.017277 0.027029 -0.044306)
      (-0.006113 0.958479 0.047634)
      (0.006379 0.248708 0.744913)))
    (tritanomaly 0.6
     ((1.104996 -0.046633 -0.058363)
      (-0.032137 0.971635 0.060503)
      (0.001336 0.317922 0.680742)))
    (tritanomaly 0.7
     ((1.193214 -0.109812 -0.083402)
      (-0.058496 0.979410 0.079086)
      (-0.002346 0.403492 0.598854)))
    (tritanomaly 0.8
     ((1.257728 -0.139648 -0.118081)
      (-0.078003 0.975409 0.102594)
      (-0.003316 0.501214 0.502102)))
    (tritanomaly 0.9
     ((1.278864 -0.125333 -0.153531)
      (-0.084748 0.957674 0.127074)
      (-0.000989 0.601151 0.399838)))
    (tritanomaly 1.0
     ((1.255528 -0.076749 -0.178779)
      (-0.078411 0.930809 0.147602)
      (0.004733 0.691367 0.303900)))
    (grayscale :json-null
     ((0.2126 0.7152 0.0722)
      (0.2126 0.7152 0.0722)
      (0.2126 0.7152 0.0722))))
  "Machado severity sweep plus a linear-sRGB grayscale diagnostic.")

(defun complementary-light-report--linear-to-srgb (channel)
  "Encode a linear RGB CHANNEL as sRGB, clamped to the display gamut."
  (let ((value (max 0.0 (min 1.0 channel))))
    (if (<= value 0.0031308)
        (* 12.92 value)
      (- (* 1.055 (expt value (/ 1.0 2.4))) 0.055))))

(defun complementary-light-report--simulate-color (hex matrix)
  "Return HEX simulated through a linear-RGB color-vision MATRIX."
  (let* ((rgb (complementary-light--hex-rgb hex))
         (linear (mapcar #'complementary-light--srgb-channel rgb))
         (simulated
          (mapcar
           (lambda (row)
             (cl-loop for coefficient in row
                      for channel in linear
                      sum (* coefficient channel)))
           matrix)))
    (complementary-light--rgb-hex
     (mapcar (lambda (channel)
               (round (* 255.0
                         (complementary-light-report--linear-to-srgb
                          channel))))
             simulated))))

(defun complementary-light-report--cie-de2000 (first second)
  "Return CIEDE2000 distance between six-digit sRGB FIRST and SECOND."
  (color-cie-de2000
   (apply #'color-srgb-to-lab
          (mapcar (lambda (channel) (/ channel 255.0))
                  (complementary-light--hex-rgb first)))
   (apply #'color-srgb-to-lab
          (mapcar (lambda (channel) (/ channel 255.0))
                  (complementary-light--hex-rgb second)))))

(defun complementary-light-report--all-distinct-accent-pairs ()
  "Return every unordered pair of distinct registered accents."
  (cl-loop for tail on complementary-light-color-names
           for primary = (car tail)
           append (cl-loop for secondary in (cdr tail)
                           collect (cons primary secondary))))

(defun complementary-light-report--color-vision-records ()
  "Return diagnostic color-vision records for both themes.
No universal CIEDE2000 accessibility threshold is assumed; these measurements
are intentionally audit data rather than a pass/fail gate."
  (let (records)
    (dolist (theme `((complementary-light . ,#'complementary-light-token)
                     (complementary-dark . ,#'complementary-dark-token)))
      (dolist (pair (complementary-light-report--all-distinct-accent-pairs))
        (dolist (role '(text state medium subtle focus))
          (let* ((primary (car pair))
                 (secondary (cdr pair))
                 (token-function (cdr theme))
                 (primary-color
                  (funcall token-function
                           (intern (format "primary-%s" role))
                           primary secondary))
                 (secondary-color
                  (funcall token-function
                           (intern (format "secondary-%s" role))
                           primary secondary))
                 (original-distance
                  (complementary-light-report--cie-de2000
                   primary-color secondary-color)))
            (dolist (simulation complementary-light-report--color-vision-matrices)
              (let* ((severity (nth 1 simulation))
                     (matrix (nth 2 simulation))
                     (simulated-primary
                      (complementary-light-report--simulate-color
                       primary-color matrix))
                     (simulated-secondary
                      (complementary-light-report--simulate-color
                       secondary-color matrix)))
                (push
                 `((theme . ,(symbol-name (car theme)))
                   (primary . ,(symbol-name primary))
                   (secondary . ,(symbol-name secondary))
                   (role . ,(symbol-name role))
                   (simulation . ,(symbol-name (car simulation)))
                   (severity . ,severity)
                   (primary_color . ,primary-color)
                   (secondary_color . ,secondary-color)
                   (simulated_primary . ,simulated-primary)
                   (simulated_secondary . ,simulated-secondary)
                   (delta_e_2000_original . ,original-distance)
                   (delta_e_2000_simulated
                    . ,(complementary-light-report--cie-de2000
                        simulated-primary simulated-secondary)))
                 records)))))))
    (nreverse records)))

(defun complementary-light-report--color-vision-pair-rankings (records)
  "Rank every distinct accent pair using diagnostic RECORDS.
The ranking key is the worst CIEDE2000 separation across both themes, all
audited roles, three Machado CVD simulations, and severities 0.1 through 1.0.
Grayscale is reported separately because it measures luminance separation
rather than a CVD model."
  (let (rankings)
    (dolist (pair (complementary-light-report--all-distinct-accent-pairs))
      (let* ((primary (symbol-name (car pair)))
             (secondary (symbol-name (cdr pair)))
             (pair-records
              (cl-remove-if-not
               (lambda (record)
                 (and (equal (cdr (assq 'primary record)) primary)
                      (equal (cdr (assq 'secondary record)) secondary)))
               records))
             (cvd-records
              (cl-remove-if
               (lambda (record)
                 (equal (cdr (assq 'simulation record)) "grayscale"))
               pair-records))
             (grayscale-records
              (cl-remove-if-not
               (lambda (record)
                 (equal (cdr (assq 'simulation record)) "grayscale"))
               pair-records))
             (worst-cvd
              (car (sort (copy-sequence cvd-records)
                         (lambda (left right)
                           (< (cdr (assq 'delta_e_2000_simulated left))
                              (cdr (assq 'delta_e_2000_simulated right)))))))
             (worst-grayscale
              (car (sort (copy-sequence grayscale-records)
                         (lambda (left right)
                           (< (cdr (assq 'delta_e_2000_simulated left))
                              (cdr (assq 'delta_e_2000_simulated right))))))))
        (push
         `((primary . ,primary)
           (secondary . ,secondary)
           (minimum_cvd_delta_e_2000
            . ,(cdr (assq 'delta_e_2000_simulated worst-cvd)))
           (minimum_grayscale_delta_e_2000
            . ,(cdr (assq 'delta_e_2000_simulated worst-grayscale)))
           (worst_cvd_context
            . ((theme . ,(cdr (assq 'theme worst-cvd)))
               (role . ,(cdr (assq 'role worst-cvd)))
               (simulation . ,(cdr (assq 'simulation worst-cvd)))
               (severity . ,(cdr (assq 'severity worst-cvd)))))
           (preset . ,(if (equal pair complementary-light-color-vision-preset)
                          t :json-false)))
         rankings)))
    (setq rankings
          (sort rankings
                (lambda (left right)
                  (> (cdr (assq 'minimum_cvd_delta_e_2000 left))
                     (cdr (assq 'minimum_cvd_delta_e_2000 right))))))
    (cl-loop for ranking in rankings
             for rank from 1
             collect (append `((rank . ,rank)) ranking))))

(defun complementary-light-report--color-vision-worst-case-records (records)
  "Condense RECORDS to the worst severity for each audited context."
  (let ((worst (make-hash-table :test #'equal)))
    (dolist (record records)
      (let* ((key (mapcar (lambda (field) (cdr (assq field record)))
                          '(theme primary secondary role simulation)))
             (existing (gethash key worst)))
        (when (or (null existing)
                  (< (cdr (assq 'delta_e_2000_simulated record))
                     (cdr (assq 'delta_e_2000_simulated existing))))
          (puthash key record worst))))
    (let (result)
      (maphash (lambda (_key record) (push record result)) worst)
      (sort result
            (lambda (left right)
              (string<
               (mapconcat (lambda (field)
                            (format "%s" (cdr (assq field left))))
                          '(theme primary secondary role simulation) "/")
               (mapconcat (lambda (field)
                            (format "%s" (cdr (assq field right))))
                          '(theme primary secondary role simulation) "/")))))))

(defun complementary-light-report--choose-face-spec (spec background-mode)
  "Choose attributes from SPEC for a true-color BACKGROUND-MODE display."
  (let* ((frame (selected-frame))
         (old-display-type (frame-parameter frame 'display-type))
         (old-background-mode (frame-parameter frame 'background-mode))
         (window-system 'pgtk))
    (unwind-protect
        (progn
          (modify-frame-parameters
           frame `((display-type . color)
                   (background-mode . ,background-mode)))
          (cl-letf (((symbol-function 'display-color-cells)
                     (lambda (&optional _display) 16777216))
                    ((symbol-function 'display-supports-face-attributes-p)
                     (lambda (&rest _arguments) t)))
            (condition-case nil
                (face-spec-choose spec frame)
              (error :unresolved))))
      (modify-frame-parameters
       frame `((display-type . ,old-display-type)
               (background-mode . ,old-background-mode))))))

(defun complementary-light-report--color-to-hex (value)
  "Return VALUE as a six-digit sRGB string, or nil when unresolved."
  (cond
   ((complementary-light-valid-hex-p value) (downcase value))
   ((stringp value)
    (when-let ((rgb (color-name-to-rgb value)))
      (downcase (apply #'color-rgb-to-hex (append rgb '(2))))))))

(defun complementary-light-report--inheritance-faces (value)
  "Return literal face symbols represented by :inherit VALUE."
  (cond
   ((and (symbolp value) (not (memq value '(nil unspecified)))) (list value))
   ((and (consp value)
         (memq (car value) (list (intern ",") (intern ",@")))
         (symbolp (cadr value)))
    (list (cadr value)))
   ((listp value)
    (cl-remove-if
     (lambda (item) (memq item (list (intern ",") (intern ",@"))))
     (cl-remove-if-not #'symbolp value)))))

(defun complementary-light-report--selected-face-attributes
    (face theme-specs background-mode)
  "Return selected attributes for FACE from THEME-SPECS or its defface."
  (if-let ((theme-spec (assq face theme-specs)))
      (complementary-light-report--choose-face-spec
       (cadr theme-spec) background-mode)
    (complementary-light-report--choose-face-spec
     (complementary-light--default-face-spec face) background-mode)))

(defun complementary-light-report--effective-face-colors
    (face theme-specs background-mode fallback seen)
  "Resolve effective colors for FACE under a static true-color display.
THEME-SPECS are generated face declarations, FALLBACK is the theme default
color pair, and SEEN prevents inheritance cycles."
  (if (or (memq face seen) (not (complementary-light-face-rule face)))
      (append fallback '(nil))
    (let* ((rule (cdr (complementary-light-face-rule face)))
           (status (plist-get rule :status)))
      (if (eq status 'alias)
          (complementary-light-report--effective-face-colors
           (plist-get rule :target) theme-specs background-mode fallback
           (cons face seen))
        (let* ((selected
                (complementary-light-report--selected-face-attributes
                 face theme-specs background-mode))
               (unresolved (eq selected :unresolved))
               (attributes (unless unresolved selected))
               (inheritance
                (or (complementary-light-report--inheritance-faces
                     (plist-get attributes :inherit))
                    (when (eq status 'inherit)
                      (complementary-light-report--inheritance-faces
                       (plist-get rule :target)))))
               inherited)
          (while (and inheritance (not inherited))
            (let ((target (pop inheritance)))
              (when target
                (setq inherited
                      (complementary-light-report--effective-face-colors
                       target theme-specs background-mode fallback
                       (cons face seen))))))
          (list
           (or (complementary-light-report--color-to-hex
                (plist-get attributes :foreground))
               (car inherited) (car fallback))
           (or (complementary-light-report--color-to-hex
                (plist-get attributes :background))
               (cadr inherited) (cadr fallback))
           (and (not unresolved)
                (or (not inherited) (nth 2 inherited)))))))))

(defconst complementary-light-report--non-text-faces
  '(vertical-border window-divider window-divider-first-pixel
    window-divider-last-pixel internal-border child-frame-border
    fill-column-indicator scroll-bar)
  "Theme faces whose color contrast represents a non-text graphic.")

(defconst complementary-light-report--intentional-hidden-faces
  '(org-hide org-indent transient-key-noop)
  "Faces whose purpose is to conceal layout or implementation text.")

(defconst complementary-light-report--decorative-faces
  '(ruler-mode-margins ruler-mode-pad whitespace-big-indent whitespace-hspace)
  "Faces whose foreground/background pair does not represent readable text.")

(defconst complementary-light-report--inactive-control-faces
  '(breakpoint-disabled mode-line-inactive tab-bar-tab-inactive
    tab-line-tab-inactive package-status-disabled)
  "Inactive controls which WCAG excludes from ordinary text contrast.")

(defun complementary-light-report--external-controlled-face-p (face rule)
  "Return non-nil when FACE or RULE obtains color from an external protocol."
  (or (eq (plist-get rule :status) 'external-semantic)
      (string-match-p
       (rx bos (or "fg:erc-color-face" "bg:erc-color-face"))
       (symbol-name face))))

(defun complementary-light-report--inventory-contrast-role (face rule)
  "Return the full-inventory contrast role for FACE described by RULE."
  (cond ((eq face 'cursor) 'contextual)
        ((complementary-light-report--external-controlled-face-p face rule)
         'external-controlled)
        ((memq face complementary-light-report--intentional-hidden-faces)
         'intentional-hidden)
        ((memq face complementary-light-report--decorative-faces)
         'decorative)
        ((memq face complementary-light-report--inactive-control-faces)
         'inactive-control)
        ((memq face complementary-light-report--non-text-faces)
         'non-text-indicator)
        (t 'normal-text)))

(defun complementary-light-report--inventory-role-threshold (role)
  "Return the WCAG review threshold for full-inventory ROLE, or nil."
  (pcase role
    ('normal-text complementary-light-wcag-text-contrast)
    ('non-text-indicator complementary-light-wcag-non-text-contrast)
    (_ nil)))

(defun complementary-light-report--effective-face-contrast-records ()
  "Return conservative effective contrast records for every inventoried face.
  The audit resolves the selected true-color clause and literal inheritance for
the default yellow/purple pairing.  Role-specific review gates exclude faces
which are hidden, decorative, inactive, contextual, or externally controlled."
  (let (records)
    (dolist (configuration
             `((complementary-light light ,#'complementary-light-token)
               (complementary-dark dark ,#'complementary-dark-token)))
      (let* ((theme (nth 0 configuration))
             (background-mode (nth 1 configuration))
             (token-function (nth 2 configuration))
             (primary 'yellow)
             (secondary 'purple)
             (theme-specs
              (if (eq theme 'complementary-light)
                  (complementary-light-build-face-specs primary secondary)
                (complementary-dark--with-palette
                  (complementary-light-build-face-specs primary secondary))))
             (fallback
              (list (funcall token-function 'foreground primary secondary)
                    (funcall token-function 'background primary secondary))))
        (dolist (entry (plist-get complementary-light-generated-inventory
                                  :faces))
          (let* ((face (car entry))
                 (rule (cdr (complementary-light-face-rule face)))
                 (colors
                  (complementary-light-report--effective-face-colors
                   face theme-specs background-mode fallback nil))
                 (foreground (car colors))
                 (background (cadr colors))
                 (auditable (nth 2 colors))
                 (ratio (and auditable
                             (complementary-light-contrast-ratio
                              foreground background)))
                 (role
                  (complementary-light-report--inventory-contrast-role
                   face rule))
                 (required
                  (complementary-light-report--inventory-role-threshold role))
                 (review-candidate
                  (and ratio required (< ratio required)))
                 (raw-below-text
                  (and ratio
                       (< ratio complementary-light-wcag-text-contrast))))
            (push
             `((theme . ,(symbol-name theme))
               (face . ,(symbol-name face))
               (classification . ,(symbol-name (plist-get rule :status)))
               (contrast_role . ,(symbol-name role))
               (auditable . ,(if auditable t :json-false))
               (foreground . ,(if auditable foreground :json-null))
               (background . ,(if auditable background :json-null))
               (ratio . ,(or ratio :json-null))
               (applicable_threshold . ,(or required :json-null))
               (passed
                . ,(if (and ratio required)
                       (if review-candidate :json-false t)
                     :json-null))
               (review_candidate
                . ,(if review-candidate t :json-false))
               (raw_below_text_minimum
                . ,(if raw-below-text t :json-false))
               ;; Retained for report consumers from version 0.2.0.  New code
               ;; should use `review_candidate', which is role-aware.
               (candidate_below_text_minimum
                . ,(if raw-below-text t :json-false)))
             records)))))
    (nreverse records)))

(defun complementary-light-report--effective-face-role (face)
  "Return the contrast audit role for FACE."
  (cond ((eq face 'cursor) 'contextual-cursor)
        ((memq face complementary-light-report--non-text-faces) 'non-text)
        (t 'text)))

(defun complementary-light-report--themed-face-worst-case-records ()
  "Return each themed face's worst effective contrast over valid accent pairs.
Unlike the full inventory snapshot, this is a focused gate over every ordered
pair of distinct accents.  Cursor contrast is contextual and is audited against
its declared surface set instead of treating the glyph beneath it as text."
  (let ((worst (make-hash-table :test #'equal)))
    (dolist (configuration
             `((complementary-light light ,#'complementary-light-token)
               (complementary-dark dark ,#'complementary-dark-token)))
      (let* ((theme (nth 0 configuration))
             (background-mode (nth 1 configuration))
             (token-function (nth 2 configuration))
            (text-target
             (if (eq theme 'complementary-light)
                 complementary-light-accent-text-contrast-target
               complementary-light-text-contrast-target))
            (non-text-target
             (if (eq theme 'complementary-light)
                 complementary-light-accent-non-text-contrast-target
               complementary-light-non-text-contrast-target)))
        (dolist (primary complementary-light-color-names)
          (dolist (secondary complementary-light-color-names)
            (unless (eq primary secondary)
              (let* ((theme-specs
                      (if (eq theme 'complementary-light)
                          (complementary-light-build-face-specs
                           primary secondary)
                        (complementary-dark--with-palette
                          (complementary-light-build-face-specs
                           primary secondary))))
                     (fallback
                      (list
                       (funcall token-function 'foreground primary secondary)
                       (funcall token-function 'background primary secondary))))
                (dolist (rule complementary-light-face-rules)
                  (when (eq (plist-get (cdr rule) :status) 'themed)
                    (let* ((face (car rule))
                           (foreground-token
                            (plist-get (cdr rule) :foreground))
                           (role
                            (complementary-light-report--effective-face-role
                             face))
                           (colors
                            (complementary-light-report--effective-face-colors
                             face theme-specs background-mode fallback nil))
                           (auditable (nth 2 colors))
                           (ratio
                            (and auditable
                                 (complementary-light-contrast-ratio
                                  (car colors) (cadr colors))))
                           (required
                            (pcase role
                              ('text
                               (if (and (eq theme 'complementary-light)
                                        (eq foreground-token
                                            'comment-foreground))
                                   complementary-light-comment-text-contrast-target
                                 text-target))
                              ('non-text non-text-target)
                              (_ nil)))
                           (key (list theme face))
                           (existing (gethash key worst)))
                      (when (and ratio
                                 (or (null existing)
                                     (< ratio (cdr (assq 'ratio existing)))))
                        (puthash
                         key
                         `((theme . ,(symbol-name theme))
                           (face . ,(symbol-name face))
                           (role . ,(symbol-name role))
                           (primary . ,(symbol-name primary))
                           (secondary . ,(symbol-name secondary))
                           (foreground . ,(car colors))
                           (background . ,(cadr colors))
                           (ratio . ,ratio)
                           (required . ,(or required :json-null))
                           (passed
                            . ,(if required
                                   (if (>= ratio required) t :json-false)
                                 :json-null)))
                         worst)))))))))))
    (let (records)
      (maphash (lambda (_key record) (push record records)) worst)
      (sort records
            (lambda (left right)
              (let ((left-theme (cdr (assq 'theme left)))
                    (right-theme (cdr (assq 'theme right))))
                (if (equal left-theme right-theme)
                    (string< (cdr (assq 'face left))
                             (cdr (assq 'face right)))
                  (string< left-theme right-theme))))))))

(defun complementary-light-report--cursor-contrast-records ()
  "Return gated cursor contrast on every declared cursor surface."
  (let (records)
    (dolist (configuration
             `((complementary-light ,#'complementary-light-token)
               (complementary-dark ,#'complementary-dark-token)))
      (let ((theme (car configuration))
            (token-function (cadr configuration)))
        (dolist (primary complementary-light-color-names)
          (dolist (secondary complementary-light-color-names)
            (unless (eq primary secondary)
              (let ((cursor
                     (funcall token-function 'cursor primary secondary)))
                (dolist (entry
                         (mapcar (lambda (token) (cons token 'gated))
                                 complementary-light-cursor-background-tokens))
                  (let* ((background-token (car entry))
                         (policy (cdr entry))
                         (background
                          (funcall token-function background-token
                                   primary secondary))
                         (ratio
                          (complementary-light-contrast-ratio
                           cursor background))
                         (required
                          (and (eq policy 'gated)
                               complementary-light-non-text-contrast-target)))
                    (push
                     `((theme . ,(symbol-name theme))
                       (primary . ,(symbol-name primary))
                       (secondary . ,(symbol-name secondary))
                       (surface . ,(symbol-name background-token))
                       (policy . ,(symbol-name policy))
                       (cursor . ,cursor)
                       (background . ,background)
                       (ratio . ,ratio)
                       (required . ,(or required :json-null))
                       (passed
                        . ,(if required
                               (if (>= ratio required) t :json-false)
                             :json-null)))
                     records)))))))))
    (nreverse records)))

(defun complementary-light-report--cursor-worst-case-records (records)
  "Condense cursor RECORDS to the weakest pair for each theme and surface."
  (let ((worst (make-hash-table :test #'equal)))
    (dolist (record records)
      (let* ((key (mapcar (lambda (field) (cdr (assq field record)))
                          '(theme surface policy)))
             (existing (gethash key worst)))
        (when (or (null existing)
                  (< (cdr (assq 'ratio record))
                     (cdr (assq 'ratio existing))))
          (puthash key record worst))))
    (let (result)
      (maphash (lambda (_key record) (push record result)) worst)
      (sort result
            (lambda (left right)
              (string< (format "%s/%s" (cdr (assq 'theme left))
                               (cdr (assq 'surface left)))
                       (format "%s/%s" (cdr (assq 'theme right))
                               (cdr (assq 'surface right)))))))))

(defun complementary-light-report-generate (directory)
  "Generate all JSON reports below DIRECTORY."
  (interactive "DReport directory: ")
  (let* ((records (complementary-light-report--contrast-records))
         (color-vision-records
          (complementary-light-report--color-vision-records))
         (color-vision-rankings
          (complementary-light-report--color-vision-pair-rankings
           color-vision-records))
         (color-vision-worst-case-records
          (complementary-light-report--color-vision-worst-case-records
           color-vision-records))
         (effective-face-records
          (complementary-light-report--effective-face-contrast-records))
         (themed-face-worst-case-records
          (complementary-light-report--themed-face-worst-case-records))
         (cursor-records
          (complementary-light-report--cursor-contrast-records))
         (cursor-worst-case-records
          (complementary-light-report--cursor-worst-case-records
           cursor-records))
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
         (inventory-roles
          '(normal-text non-text-indicator intentional-hidden decorative
            inactive-control external-controlled contextual))
         (effective-role-counts
          (mapcar
           (lambda (role)
             (cons
              (symbol-name role)
              (cl-count (symbol-name role) effective-face-records
                        :test #'equal
                        :key (lambda (record)
                               (cdr (assq 'contrast_role record))))))
           inventory-roles))
         (effective-review-candidate-count
          (cl-count-if
           (lambda (record)
             (eq (cdr (assq 'review_candidate record)) t))
           effective-face-records))
         (effective-raw-below-text-count
          (cl-count-if
           (lambda (record)
             (eq (cdr (assq 'raw_below_text_minimum record)) t))
           effective-face-records))
         (metadata (plist-get complementary-light-generated-inventory :metadata)))
    (complementary-light-report--write
     (expand-file-name "palette-contrast.json" directory) records)
    (complementary-light-report--write
     (expand-file-name "face-coverage.json" directory)
     (complementary-light-report--coverage-records))
    (complementary-light-report--write
     (expand-file-name "color-vision.json" directory)
     `((policy . "diagnostic-only")
       (model . "Machado-Oliveira-Fernandes severities 0.1-1.0 plus linear-sRGB grayscale")
       (metric . "CIEDE2000")
       (scope . "model-relative ranking; not a universal perceptual threshold")
       (metric_limit . "CIEDE2000 is primarily validated for small adjacent color differences")
       (preset . ((primary . ,(symbol-name
                                (car complementary-light-color-vision-preset)))
                  (secondary . ,(symbol-name
                                  (cdr complementary-light-color-vision-preset)))
                  (selection_basis
                   . "best worst-case pair within this model, role set, and severity sweep")))
       (evaluated_record_count . ,(length color-vision-records))
       (reported_worst_case_record_count
        . ,(length color-vision-worst-case-records))
       (pair_rankings . ,color-vision-rankings)
       (worst_case_records . ,color-vision-worst-case-records)))
    (complementary-light-report--write
     (expand-file-name "effective-face-contrast.json" directory)
     `((policy . "role-aware-conservative-static-audit")
       (display . "true-color pgtk simulation")
       (pair . ((primary . "yellow") (secondary . "purple")))
       (text_review_threshold . ,complementary-light-wcag-text-contrast)
       (non_text_review_threshold . ,complementary-light-wcag-non-text-contrast)
       (caveat . "Review candidates are role-gated; real GUI rendering and contextual overlaps still require visual validation.")
       (role_counts . ,effective-role-counts)
       (candidate_count . ,effective-review-candidate-count)
       (raw_below_text_minimum_count . ,effective-raw-below-text-count)
       (unauditable_count
        . ,(cl-count-if
            (lambda (record)
              (eq (cdr (assq 'auditable record)) :json-false))
            effective-face-records))
       (records . ,effective-face-records)
       (themed_worst_case
        . ((pair_scope . "all 132 ordered pairs of distinct accents")
           (targets
            . ((complementary-light
                . ((text . ,complementary-light-accent-text-contrast-target)
                   (non_text . ,complementary-light-accent-non-text-contrast-target)))
               (complementary-dark
                . ((text . ,complementary-light-text-contrast-target)
                   (non_text . ,complementary-light-non-text-contrast-target)))))
           (failure_count
            . ,(cl-count-if
                (lambda (record)
                  (eq (cdr (assq 'passed record)) :json-false))
                themed-face-worst-case-records))
           (records . ,themed-face-worst-case-records)))))
    (complementary-light-report--write
     (expand-file-name "cursor-surface-contrast.json" directory)
     `((policy . "all-declared-surfaces-gated")
       (gated_target . ,complementary-light-non-text-contrast-target)
       (evaluated_record_count . ,(length cursor-records))
       (reported_worst_case_record_count
        . ,(length cursor-worst-case-records))
       (gated_failure_count
        . ,(cl-count-if
            (lambda (record)
              (eq (cdr (assq 'passed record)) :json-false))
            cursor-records))
       (worst_case_records . ,cursor-worst-case-records)))
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
       (terminal_256 . ((selector . "class=color,min-colors=256")
                        (colors . "xterm-256 post-quantization contrast correction")
                        (text_minimum . ,complementary-light-wcag-text-contrast)
                        (non_color_attributes . "preserved from default defface specs")))
       (terminal_low_color . ((selector . "class=color,min-colors=16")
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
       (truecolor_contrast_targets
        . ((complementary-light
            . ((neutral_text . ,complementary-light-text-contrast-target)
               (comment_text_minimum . ,complementary-light-comment-text-contrast-target)
               (comment_text_maximum . ,complementary-light-comment-text-contrast-maximum)
               (accent_text . ,complementary-light-accent-text-contrast-target)
               (neutral_non_text . ,complementary-light-non-text-contrast-target)
               (accent_non_text . ,complementary-light-accent-non-text-contrast-target)))
           (complementary-dark
            . ((neutral_text . ,complementary-light-text-contrast-target)
               (comment_text_minimum . ,complementary-light-text-contrast-target)
               (comment_text_maximum . :json-null)
               (accent_text . ,complementary-light-text-contrast-target)
               (neutral_non_text . ,complementary-light-non-text-contrast-target)
               (accent_non_text . ,complementary-light-non-text-contrast-target)))))
       (terminal_text_contrast_minimum
        . ,complementary-light-wcag-text-contrast)
       (minimum_measured_contrast . ,(apply #'min ratios))
       (minimum_measured_contrast_by_theme . ,minimum-by-theme)
       (color_vision_policy . "diagnostic-only")
       (color_vision_record_count . ,(length color-vision-records))
       (color_vision_reported_worst_case_record_count
        . ,(length color-vision-worst-case-records))
       (color_vision_preset_minimum_delta_e_2000
        . ,(cdr (assq 'minimum_cvd_delta_e_2000
                      (car color-vision-rankings))))
       (effective_face_contrast_record_count
        . ,(length effective-face-records))
       (effective_face_review_candidate_count
        . ,effective-review-candidate-count)
       (effective_face_raw_below_text_minimum_count
        . ,effective-raw-below-text-count)
       (effective_face_role_counts . ,effective-role-counts)
       (effective_face_unauditable_count
        . ,(cl-count-if
            (lambda (record)
              (eq (cdr (assq 'auditable record)) :json-false))
            effective-face-records))
       (themed_face_worst_case_failure_count
        . ,(cl-count-if
            (lambda (record)
              (eq (cdr (assq 'passed record)) :json-false))
            themed-face-worst-case-records))
       (cursor_surface_record_count . ,(length cursor-records))
       (cursor_gated_failure_count
        . ,(cl-count-if
            (lambda (record)
              (eq (cdr (assq 'passed record)) :json-false))
            cursor-records))
       (minimum_simulated_pair_delta_e_2000
        . ,(apply #'min
                  (mapcar
                   (lambda (record)
                     (cdr (assq 'delta_e_2000_simulated record)))
                   color-vision-records)))
       (minimum_cvd_pair_delta_e_2000
        . ,(apply
            #'min
            (cl-loop for record in color-vision-records
                     unless (equal (cdr (assq 'simulation record))
                                   "grayscale")
                     collect (cdr (assq 'delta_e_2000_simulated record)))))
       (minimum_grayscale_pair_delta_e_2000
        . ,(apply
            #'min
            (cl-loop for record in color-vision-records
                     when (equal (cdr (assq 'simulation record)) "grayscale")
                     collect (cdr (assq 'delta_e_2000_simulated record)))))
       (generated_at . ,(format-time-string "%Y-%m-%dT%H:%M:%S%z"))))))

(provide 'complementary-light-generate-reports)
;;; complementary-light-generate-reports.el ends here
