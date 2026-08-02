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

(defconst complementary-themes-palette-svg-width 1600)

(defconst complementary-themes-palette-svg-height 3120)

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
    x y 352 82 surface border 12 1)
   (complementary-themes-palette-svg--rect
    (+ x 14) (+ y 12) 58 58 color border 8 1)
   (complementary-themes-palette-svg--text
    (+ x 88) (+ y 34) (symbol-name name) foreground 14 "600")
   (complementary-themes-palette-svg--text
    (+ x 88) (+ y 62) color muted 15)))

(defun complementary-themes-palette-svg--role-band
    (x y width role background foreground)
  "Return a semantic ROLE band at X, Y with WIDTH.
BACKGROUND and FOREGROUND demonstrate the intended color pair."
  (concat
   (complementary-themes-palette-svg--rect
    x y width 64 background nil 8)
   (complementary-themes-palette-svg--text
    (+ x 16) (+ y 40) role foreground 17 "600")
   (complementary-themes-palette-svg--text
    (+ x width -16) (+ y 40)
    (format "%s / %s" background foreground) foreground 15 "400" "end")))

(defun complementary-themes-palette-svg--line-role
    (x y width role color foreground)
  "Return a compact line-role sample at X, Y with WIDTH.
ROLE names COLOR and FOREGROUND colors the label text."
  (concat
   (complementary-themes-palette-svg--rect x y width 8 color nil 4)
   (complementary-themes-palette-svg--text
    x (+ y 31) role foreground 14 "600")
   (complementary-themes-palette-svg--text
    x (+ y 54) color foreground 14)))

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
      x y 724 366 surface border 16 1)
     (complementary-themes-palette-svg--text
      (+ x 20) (+ y 40) (symbol-name name) text 25 "700")
     (complementary-themes-palette-svg--text
      (+ x 704) (+ y 39) (format "text  %s" text) text 16 "600" "end")
     (complementary-themes-palette-svg--role-band
      (+ x 16) (+ y 62) 692 "strong / on-strong" strong on-strong)
     (complementary-themes-palette-svg--role-band
      (+ x 16) (+ y 136) 692 "medium / on-medium" medium on-medium)
     (complementary-themes-palette-svg--role-band
      (+ x 16) (+ y 210) 692 "subtle / on-subtle" subtle on-subtle)
     (complementary-themes-palette-svg--line-role
      (+ x 16) (+ y 292) 210 "border" accent-border foreground)
     (complementary-themes-palette-svg--line-role
      (+ x 257) (+ y 292) 210 "focus" focus foreground)
     (complementary-themes-palette-svg--line-role
      (+ x 498) (+ y 292) 210 "distant" distant muted))))

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
               64 80 (format "COMPLEMENTARY %s" (upcase name))
               foreground 40 "700"))
      (insert (complementary-themes-palette-svg--text
               64 120 "12 accents · 10 semantic roles · 5 accent tones each"
               muted 18))
      (insert (complementary-themes-palette-svg--text
               64 166 "NEUTRAL PALETTE" foreground 18 "700"))
      (cl-loop for (token . color) in neutral
               for index from 0
               for column = (% index 4)
               for row = (/ index 4)
               do (insert
                   (complementary-themes-palette-svg--neutral-card
                    (+ 64 (* column 368)) (+ 188 (* row 94)) token color
                    surface border foreground muted)))
      (insert (complementary-themes-palette-svg--text
               64 680 "ACCENT PALETTES" foreground 18 "700"))
      (cl-loop for entry in palettes
               for accent = (car entry)
               for palette = (cdr entry)
               for index from 0
               for column = (% index 2)
               for row = (/ index 2)
               do (insert
                   (complementary-themes-palette-svg--accent-card
                    (+ 64 (* column 748)) (+ 704 (* row 388)) accent palette
                    surface border foreground muted)))
      (insert (complementary-themes-palette-svg--text
               64 3078
               "Generated from lisp/complementary-light-palette.el and complementary-dark-palette.el"
               muted 15))
      (insert "</svg>\n")
      (buffer-string))))

(defun complementary-themes-palette-svg--pair-stack
    (x y width name palette foreground)
  "Return one palette stack at X, Y with WIDTH.
NAME and PALETTE identify the accent; FOREGROUND colors its label."
  (let ((band-height 30))
    (concat
     (complementary-themes-palette-svg--text
      (+ x (/ width 2)) y (symbol-name name) foreground 17 "700" "middle")
     (cl-loop for role in '(:text :strong :medium :subtle)
              for index from 0
              concat
              (complementary-themes-palette-svg--rect
               x (+ y 16 (* index band-height)) width band-height
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
      x y 476 200 surface border 14 1)
     (complementary-themes-palette-svg--pair-stack
      (+ x 18) (+ y 38) 180 left-name left foreground)
     (complementary-themes-palette-svg--text
      (+ x 238) (+ y 112) "+" foreground 26 "700" "middle")
     (complementary-themes-palette-svg--pair-stack
      (+ x 278) (+ y 38) 180 right-name right foreground))))

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
      40 y 1520 500 background border 18 1)
     (complementary-themes-palette-svg--text
      64 (+ y 42) (upcase (symbol-name variant)) foreground 22 "700")
     (complementary-themes-palette-svg--text
      1536 (+ y 42) "text · strong · medium · subtle" muted 16 "400" "end")
     (cl-loop for (left . right) in pairs
              for index from 0
              for column = (% index 3)
              for row = (/ index 3)
              concat
              (complementary-themes-palette-svg--pair-card
               (+ 64 (* column 496)) (+ y 64 (* row 216)) left right palettes
               surface border foreground)))))

(defun complementary-themes-palette-svg--pair-document ()
  "Return the SVG overview of the six symmetric accent pairs."
  (let ((pairs (cl-loop for pair on complementary-light-accent-pairs by #'cddr
                        collect (car pair))))
    (with-temp-buffer
      (insert
       (complementary-themes-palette-svg--header
        1600 1220 "Complementary accent pairs"
        (concat "The six symmetric, UI-adjusted automatic accent pairings,"
                " shown with text, strong, medium, and subtle roles in both themes.")
        "#f7f7f5"))
      (insert (complementary-themes-palette-svg--text
               64 74 "AUTOMATIC ACCENT PAIRS" "#404040" 38 "700"))
      (insert (complementary-themes-palette-svg--text
               64 112 "Six symmetric UI-adjusted pairings · secondary = auto"
               "#686868" 18))
      (insert
       (complementary-themes-palette-svg--pair-section
        140 'light complementary-light-neutral-palette
        complementary-light-palettes pairs))
      (insert
       (complementary-themes-palette-svg--pair-section
        660 'dark complementary-dark-neutral-palette
        complementary-dark-palettes pairs))
      (insert (complementary-themes-palette-svg--text
               64 1195 "Pairs are symmetric: either color may be primary."
               "#686868" 15))
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
