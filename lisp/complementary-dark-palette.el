;;; complementary-dark-palette.el --- Dark palettes for complementary themes  -*- lexical-binding: t; -*-

;; Copyright (C) 2026
;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:

;; Dark-background counterparts to the semantic palettes in
;; `complementary-light-palette.el'.  The shared face declarations consume
;; these values through `complementary-dark-token'.

;;; Code:

(require 'complementary-light-palette)

(defconst complementary-dark-neutral-palette
  (let ((base "#171717")
        (raised "#232323")
        (sunken "#1d1d1d")
        (text "#b0b0b0")
        (secondary "#929292")
        (faint "#888888")
        (edge "#6d6d6d")
        (selection "#30302f")
        (cursor "#ffffff"))
    `((background . ,base)
      (surface . ,base)
      (surface-raised . ,raised)
      (surface-sunken . ,sunken)
      (foreground . ,text)
      (foreground-secondary . ,secondary)
      (foreground-muted . ,text)
      (foreground-faint . ,faint)
      (comment-foreground . ,faint)
      (border . ,edge)
      (border-strong . ,edge)
      (divider . ,edge)
      (selection-neutral . ,selection)
      (inactive-background . ,base)
      (inactive-foreground . ,secondary)
      (cursor . ,cursor)
      (distant-foreground . ,text)))
  "Neutral colors used by `complementary-dark'.")

(defun complementary-dark--make-accent-palette
    (text strong medium subtle border)
  "Return a dark accent palette from its five accent-specific tones.
TEXT is reused on dark accent surfaces and for distant text.  BORDER also
supplies focus indicators.  Text on STRONG uses the neutral cursor color."
  (list :text text
        :strong strong
        :on-strong (alist-get 'cursor complementary-dark-neutral-palette)
        :medium medium
        :on-medium text
        :subtle subtle
        :on-subtle text
        :border border
        :focus border
        :distant-foreground text))

(defconst complementary-dark-palettes
  (list
   (cons 'red (complementary-dark--make-accent-palette
               "#dba0aa" "#9b3649" "#7f0018" "#442228" "#aa495b"))
   (cons 'orange (complementary-dark--make-accent-palette
                  "#dea378" "#7d4f2c" "#652b00" "#39291c" "#8d5f3c"))
   (cons 'yellow (complementary-dark--make-accent-palette
                  "#cbad4b" "#685824" "#4b3a00" "#322c18" "#796834"))
   (cons 'green (complementary-dark--make-accent-palette
                 "#61c46d" "#24662c" "#004709" "#18321b" "#34773c"))
   (cons 'teal (complementary-dark--make-accent-palette
                "#3bc3b5" "#23635d" "#00453f" "#18302e" "#33736c"))
   (cons 'cyan (complementary-dark--make-accent-palette
                "#3bbfd9" "#26616c" "#004351" "#1a2f34" "#36717c"))
   (cons 'blue (complementary-dark--make-accent-palette
                "#84b5e0" "#2f5d86" "#003c77" "#1e2e3c" "#3f6d95"))
   (cons 'indigo (complementary-dark--make-accent-palette
                  "#a4aedc" "#3e51af" "#0020ba" "#242a49" "#5162bb"))
   (cons 'purple (complementary-dark--make-accent-palette
                  "#c2a4dc" "#773ca9" "#5600a2" "#372448" "#874eb8"))
   (cons 'magenta (complementary-dark--make-accent-palette
                   "#d99ec7" "#943476" "#770054" "#422138" "#a54687"))
   (cons 'rose (complementary-dark--make-accent-palette
                "#daa0b5" "#983659" "#7d002d" "#44212e" "#a9486b"))
   (cons 'amber (complementary-dark--make-accent-palette
                 "#d7a945" "#6d5626" "#513800" "#332b19" "#7c6635")))
  "Contrast-checked accent palettes for a dark background.")

(defun complementary-dark--restore-contrast-requirement (pair)
  "Return dark-theme PAIR with the original stricter contrast requirement."
  (pcase-let ((`(,foreground ,background ,required) pair))
    (list foreground background
          (cond
           ((= required complementary-light-accent-text-contrast-target)
            complementary-light-text-contrast-target)
           ((= required complementary-light-comment-text-contrast-target)
            complementary-light-text-contrast-target)
           ((= required complementary-light-accent-non-text-contrast-target)
            complementary-light-non-text-contrast-target)
           (t required)))))

(defconst complementary-dark-contrast-pairs
  (mapcar #'complementary-dark--restore-contrast-requirement
          complementary-light-contrast-pairs)
  "Dark palette pairs using the original high-contrast requirements.")

(defconst complementary-dark-overlap-scenarios
  (mapcar
   (lambda (scenario)
     (cons (car scenario)
           (complementary-dark--restore-contrast-requirement (cdr scenario))))
   complementary-light-overlap-scenarios)
  "Dark overlap scenarios using the original high-contrast requirements.")

(defmacro complementary-dark--with-palette (&rest body)
  "Evaluate BODY using the dark neutral and accent palettes."
  (declare (indent 0) (debug t))
  `(let ((complementary-light-neutral-palette
          complementary-dark-neutral-palette)
         (complementary-light-palettes complementary-dark-palettes))
     ,@body))

(defun complementary-dark-palette (name &optional noerror)
  "Return dark registered palette NAME.
Signal `user-error' unless NOERROR is non-nil when NAME is unknown."
  (complementary-dark--with-palette
    (complementary-light-palette name noerror)))

(defun complementary-dark-resolve-secondary (primary secondary &optional startup)
  "Resolve dark SECONDARY for PRIMARY.
STARTUP has the same meaning as in `complementary-light-resolve-secondary'."
  (complementary-dark--with-palette
    (complementary-light-resolve-secondary primary secondary startup)))

(defun complementary-dark-token (token primary secondary)
  "Resolve dark semantic TOKEN using PRIMARY and SECONDARY accent names."
  (complementary-dark--with-palette
    (complementary-light-token token primary secondary)))

(defun complementary-dark-validate-palettes ()
  "Return nil or signal an error describing the first dark palette defect."
  (complementary-dark--with-palette
    (complementary-light-validate-palettes)))

(provide 'complementary-dark-palette)
;;; complementary-dark-palette.el ends here
