;;; complementary-themes-generate-palettes.el --- Generate palette SVGs  -*- lexical-binding: t; -*-

;; Copyright (C) 2026
;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:

;; Generate deterministic, self-contained SVG references from the palette
;; constants used by the light and dark themes.  The generated files are
;; documentation artifacts; the Emacs Lisp palette definitions remain the
;; source of truth.

;;; Code:

(require 'cl-lib)
(require 'subr-x)
(require 'complementary-light-palette)
(require 'complementary-dark-palette)

(defconst complementary-themes-palette-svg-width 1440)

(defconst complementary-themes-palette-svg-height 2048)

(defconst complementary-themes-palette-svg-font-family
  "ui-monospace, SFMono-Regular, Menlo, Consolas, Liberation Mono, monospace")

(defun complementary-themes-palette-svg--write (file contents)
  "Write CONTENTS to FILE, creating its parent directory when necessary."
  (make-directory (file-name-directory file) t)
  (with-temp-file file
    (set-buffer-file-coding-system 'utf-8-unix)
    (insert contents)))

(defun complementary-themes-palette-svg--header
    (width height title description background)
  "Return an SVG header for WIDTH, HEIGHT, TITLE, and DESCRIPTION.
BACKGROUND fills the canvas."
  (format (concat
           "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
           "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"%d\" height=\"%d\""
           " viewBox=\"0 0 %d %d\" role=\"img\" aria-labelledby=\"title desc\">\n"
           "  <title id=\"title\">%s</title>\n"
           "  <desc id=\"desc\">%s</desc>\n"
           "  <rect width=\"%d\" height=\"%d\" fill=\"%s\"/>\n")
          width height width height title description width height background))

(defun complementary-themes-palette-svg--text
    (x y text fill size &optional weight anchor)
  "Return SVG text at X and Y displaying TEXT.
FILL, SIZE, WEIGHT, and ANCHOR control its presentation."
  (format (concat "  <text x=\"%d\" y=\"%d\" fill=\"%s\" font-family=\"%s\""
                  " font-size=\"%d\" font-weight=\"%s\" text-anchor=\"%s\">%s</text>\n")
          x y fill complementary-themes-palette-svg-font-family size
          (or weight "400") (or anchor "start") text))

(defun complementary-themes-palette-svg--rect
    (x y width height fill &optional stroke radius stroke-width)
  "Return an SVG rectangle at X, Y with WIDTH, HEIGHT, and FILL.
STROKE, RADIUS, and STROKE-WIDTH are optional."
  (format (concat "  <rect x=\"%d\" y=\"%d\" width=\"%d\" height=\"%d\""
                  " rx=\"%d\" fill=\"%s\"%s/>\n")
          x y width height (or radius 0) fill
          (if stroke
              (format " stroke=\"%s\" stroke-width=\"%d\""
                      stroke (or stroke-width 1))
            "")))

(defun complementary-themes-palette-svg--neutral-card
    (x y name color surface border foreground muted)
  "Return a neutral palette card at X, Y for NAME and COLOR.
SURFACE, BORDER, FOREGROUND, and MUTED supply the card colors."
  (concat
   (complementary-themes-palette-svg--rect
    x y 208 72 surface border 10 1)
   (complementary-themes-palette-svg--rect
    (+ x 12) (+ y 12) 48 48 color border 7 1)
   (complementary-themes-palette-svg--text
    (+ x 72) (+ y 30) (symbol-name name) foreground 11 "600")
   (complementary-themes-palette-svg--text
    (+ x 72) (+ y 52) color muted 12)))

(defun complementary-themes-palette-svg--role-band
    (x y width role background foreground)
  "Return a semantic ROLE band at X, Y with WIDTH.
BACKGROUND and FOREGROUND demonstrate the intended color pair."
  (concat
   (complementary-themes-palette-svg--rect
    x y width 55 background nil 7)
   (complementary-themes-palette-svg--text
    (+ x 14) (+ y 34) role foreground 14 "600")
   (complementary-themes-palette-svg--text
    (+ x width -14) (+ y 34)
    (format "%s / %s" background foreground) foreground 12 "400" "end")))

(defun complementary-themes-palette-svg--line-role
    (x y width role color foreground)
  "Return a compact line-role sample at X, Y with WIDTH.
ROLE names COLOR and FOREGROUND colors the label text."
  (concat
   (complementary-themes-palette-svg--rect x y width 6 color nil 3)
   (complementary-themes-palette-svg--text
    x (+ y 25) role foreground 11 "600")
   (complementary-themes-palette-svg--text
    x (+ y 42) color foreground 11)))

(defun complementary-themes-palette-svg--accent-card
    (x y name palette surface border foreground muted)
  "Return an accent card at X, Y for NAME and PALETTE.
SURFACE, BORDER, FOREGROUND, and MUTED supply neutral presentation colors."
  (let ((text (plist-get palette :text))
        (strong (plist-get palette :strong))
        (on-strong (plist-get palette :on-strong))
        (medium (plist-get palette :medium))
        (on-medium (plist-get palette :on-medium))
        (subtle (plist-get palette :subtle))
        (on-subtle (plist-get palette :on-subtle))
        (accent-border (plist-get palette :border))
        (focus (plist-get palette :focus))
        (distant (plist-get palette :distant-foreground)))
    (concat
     (complementary-themes-palette-svg--rect
      x y 424 350 surface border 14 1)
     (complementary-themes-palette-svg--text
      (+ x 18) (+ y 33) (symbol-name name) text 20 "700")
     (complementary-themes-palette-svg--text
      (+ x 406) (+ y 32) (format "text  %s" text) text 13 "600" "end")
     (complementary-themes-palette-svg--role-band
      (+ x 16) (+ y 52) 392 "strong / on-strong" strong on-strong)
     (complementary-themes-palette-svg--role-band
      (+ x 16) (+ y 115) 392 "medium / on-medium" medium on-medium)
     (complementary-themes-palette-svg--role-band
      (+ x 16) (+ y 178) 392 "subtle / on-subtle" subtle on-subtle)
     (complementary-themes-palette-svg--line-role
      (+ x 16) (+ y 255) 114 "border" accent-border foreground)
     (complementary-themes-palette-svg--line-role
      (+ x 146) (+ y 255) 114 "focus" focus foreground)
     (complementary-themes-palette-svg--line-role
      (+ x 276) (+ y 255) 132 "distant" distant muted))))

(defun complementary-themes-palette-svg--palette-document (variant)
  "Return the complete palette SVG for VARIANT, either `light' or `dark'."
  (let* ((darkp (eq variant 'dark))
         (neutral (if darkp
                      complementary-dark-neutral-palette
                    complementary-light-neutral-palette))
         (palettes (if darkp
                       complementary-dark-palettes
                     complementary-light-palettes))
         (background (alist-get 'background neutral))
         (surface (alist-get 'surface-raised neutral))
         (border (alist-get 'border neutral))
         (foreground (alist-get 'foreground neutral))
         (muted (alist-get 'foreground-faint neutral))
         (name (capitalize (symbol-name variant))))
    (with-temp-buffer
      (insert
       (complementary-themes-palette-svg--header
        complementary-themes-palette-svg-width
        complementary-themes-palette-svg-height
        (format "Complementary %s palette" name)
        (format (concat "The neutral palette and all twelve %s-theme accent palettes,"
                        " including their semantic text, surface, border, focus,"
                        " and distant foreground roles.")
                (symbol-name variant))
        background))
      (insert (complementary-themes-palette-svg--text
               64 76 (format "COMPLEMENTARY %s" (upcase name))
               foreground 34 "700"))
      (insert (complementary-themes-palette-svg--text
               64 110 "12 accents · 10 semantic roles each · 8-bit sRGB"
               muted 16))
      (insert (complementary-themes-palette-svg--text
               64 158 "NEUTRAL PALETTE" foreground 15 "700"))
      (cl-loop for (token . color) in neutral
               for index from 0
               for column = (% index 6)
               for row = (/ index 6)
               do (insert
                   (complementary-themes-palette-svg--neutral-card
                    (+ 64 (* column 221)) (+ 180 (* row 84)) token color
                    surface border foreground muted)))
      (insert (complementary-themes-palette-svg--text
               64 456 "ACCENT PALETTES" foreground 15 "700"))
      (cl-loop for entry in palettes
               for accent = (car entry)
               for palette = (cdr entry)
               for index from 0
               for column = (% index 3)
               for row = (/ index 3)
               do (insert
                   (complementary-themes-palette-svg--accent-card
                    (+ 64 (* column 444)) (+ 480 (* row 370)) accent palette
                    surface border foreground muted)))
      (insert (complementary-themes-palette-svg--text
               64 2010
               "Generated from lisp/complementary-light-palette.el and complementary-dark-palette.el"
               muted 13))
      (insert "</svg>\n")
      (buffer-string))))

(defun complementary-themes-palette-svg--pair-stack
    (x y width name palette foreground)
  "Return one palette stack at X, Y with WIDTH.
NAME and PALETTE identify the accent; FOREGROUND colors its label."
  (let ((band-height 22))
    (concat
     (complementary-themes-palette-svg--text
      (+ x (/ width 2)) y (symbol-name name) foreground 13 "700" "middle")
     (cl-loop for role in '(:text :strong :medium :subtle)
              for index from 0
              concat
              (complementary-themes-palette-svg--rect
               x (+ y 12 (* index band-height)) width band-height
               (plist-get palette role) nil
               (cond ((= index 0) 6)
                     ((= index 3) 6)
                     (t 0)))))))

(defun complementary-themes-palette-svg--pair-card
    (x y left-name right-name palettes surface border foreground)
  "Return an accent pair card at X, Y.
LEFT-NAME and RIGHT-NAME select colors from PALETTES.  SURFACE, BORDER, and
FOREGROUND provide neutral presentation colors."
  (let ((left (cdr (assq left-name palettes)))
        (right (cdr (assq right-name palettes))))
    (concat
     (complementary-themes-palette-svg--rect
      x y 208 154 surface border 12 1)
     (complementary-themes-palette-svg--pair-stack
      (+ x 18) (+ y 31) 76 left-name left foreground)
     (complementary-themes-palette-svg--text
      (+ x 104) (+ y 88) "+" foreground 18 "700" "middle")
     (complementary-themes-palette-svg--pair-stack
      (+ x 114) (+ y 31) 76 right-name right foreground))))

(defun complementary-themes-palette-svg--pair-section
    (y variant neutral palettes pairs)
  "Return one pairing section at Y for VARIANT.
NEUTRAL and PALETTES provide colors, while PAIRS lists the six pairings."
  (let ((background (alist-get 'background neutral))
        (surface (alist-get 'surface-raised neutral))
        (border (alist-get 'border neutral))
        (foreground (alist-get 'foreground neutral))
        (muted (alist-get 'foreground-faint neutral)))
    (concat
     (complementary-themes-palette-svg--rect
      40 y 1360 244 background border 16 1)
     (complementary-themes-palette-svg--text
      64 (+ y 40) (upcase (symbol-name variant)) foreground 18 "700")
     (complementary-themes-palette-svg--text
      1336 (+ y 39) "text · strong · medium · subtle" muted 13 "400" "end")
     (cl-loop for (left . right) in pairs
              for index from 0
              concat
              (complementary-themes-palette-svg--pair-card
               (+ 64 (* index 218)) (+ y 64) left right palettes
               surface border foreground)))))

(defun complementary-themes-palette-svg--pair-document ()
  "Return the SVG overview of the six symmetric accent pairs."
  (let ((pairs (cl-loop for pair on complementary-light-accent-pairs by #'cddr
                        collect (car pair))))
    (with-temp-buffer
      (insert
       (complementary-themes-palette-svg--header
        1440 700 "Complementary accent pairs"
        (concat "The six symmetric, UI-adjusted automatic accent pairings,"
                " shown with text, strong, medium, and subtle roles in both themes.")
        "#f7f7f5"))
      (insert (complementary-themes-palette-svg--text
               64 70 "AUTOMATIC ACCENT PAIRS" "#404040" 32 "700"))
      (insert (complementary-themes-palette-svg--text
               64 103 "Six symmetric UI-adjusted pairings · secondary = auto"
               "#686868" 16))
      (insert
       (complementary-themes-palette-svg--pair-section
        132 'light complementary-light-neutral-palette
        complementary-light-palettes pairs))
      (insert
       (complementary-themes-palette-svg--pair-section
        396 'dark complementary-dark-neutral-palette
        complementary-dark-palettes pairs))
      (insert (complementary-themes-palette-svg--text
               64 675 "Pairs are symmetric: either color may be primary."
               "#686868" 13))
      (insert "</svg>\n")
      (buffer-string))))

;;;###autoload
(defun complementary-themes-generate-palette-svgs (directory)
  "Generate all palette SVG documentation artifacts in DIRECTORY."
  (interactive "DOutput directory: ")
  (let ((directory (file-name-as-directory (expand-file-name directory))))
    (complementary-themes-palette-svg--write
     (expand-file-name "complementary-light.svg" directory)
     (complementary-themes-palette-svg--palette-document 'light))
    (complementary-themes-palette-svg--write
     (expand-file-name "complementary-dark.svg" directory)
     (complementary-themes-palette-svg--palette-document 'dark))
    (complementary-themes-palette-svg--write
     (expand-file-name "accent-pairs.svg" directory)
     (complementary-themes-palette-svg--pair-document))))

(provide 'complementary-themes-generate-palettes)
;;; complementary-themes-generate-palettes.el ends here
