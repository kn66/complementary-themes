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
  '((background . "#171717")
    (surface . "#171717")
    (surface-raised . "#232323")
    (surface-sunken . "#1d1d1d")
    (foreground . "#a7a7a7")
    (foreground-secondary . "#8a8a8a")
    (foreground-muted . "#a7a7a7")
    (foreground-faint . "#808080")
    (border . "#646464")
    (border-strong . "#686868")
    (divider . "#646464")
    (selection-neutral . "#30302f")
    (inactive-background . "#202020")
    (inactive-foreground . "#878787")
    (distant-foreground . "#a7a7a7"))
  "Neutral colors used by `complementary-dark'.")

(defconst complementary-dark-palettes
  '((red
     :text "#d795a1" :strong "#9b3649" :on-strong "#e1cbcf"
     :medium "#642934" :on-medium "#d694a0"
     :subtle "#442228" :on-subtle "#cb7c8a"
     :border "#a74154" :focus "#994c5a"
     :distant-foreground "#cd98a2")
    (orange
     :text "#da9867" :strong "#7d4f2c" :on-strong "#ddcec2"
     :medium "#523621" :on-medium "#da9765"
     :subtle "#39291c" :on-subtle "#d17f42"
     :border "#895935" :focus "#815c40"
     :distant-foreground "#ca9d7b")
    (yellow
     :text "#c5a336" :strong "#685824" :on-strong "#d7d0b8"
     :medium "#453c1c" :on-medium "#c5a336"
     :subtle "#322c18" :on-subtle "#ae902f"
     :border "#74622d" :focus "#706337"
     :distant-foreground "#bba55f")
    (green
     :text "#4dbc5b" :strong "#24662c" :on-strong "#b9d8bd"
     :medium "#1c4521" :on-medium "#4dbc5b"
     :subtle "#18321b" :on-subtle "#47a653"
     :border "#2c7134" :focus "#37703e"
     :distant-foreground "#6bb874")
    (teal
     :text "#1fbaab" :strong "#23635d" :on-strong "#b7d6d3"
     :medium "#1b433f" :on-medium "#1fbaab"
     :subtle "#18302e" :on-subtle "#1ca497"
     :border "#2b6e67" :focus "#356d67"
     :distant-foreground "#3eb8ac")
    (cyan
     :text "#21b6d4" :strong "#26616c" :on-strong "#bcd4d9"
     :medium "#1d4148" :on-medium "#21b5d2"
     :subtle "#1a2f34" :on-subtle "#1da0ba"
     :border "#2f6c78" :focus "#396b74"
     :distant-foreground "#50b3c6")
    (blue
     :text "#76acdd" :strong "#2f5d86" :on-strong "#c5d2de"
     :medium "#243e57" :on-medium "#74abdd"
     :subtle "#1e2e3c" :on-subtle "#5598d5"
     :border "#386791" :focus "#436788"
     :distant-foreground "#83aacd")
    (indigo
     :text "#99a4d8" :strong "#3e51af" :on-strong "#cbcfe2"
     :medium "#2d386e" :on-medium "#98a3d8"
     :subtle "#242a49" :on-subtle "#848fca"
     :border "#4a5cb8" :focus "#515fa3"
     :distant-foreground "#9ba4cf")
    (purple
     :text "#bb99d8" :strong "#773ca9" :on-strong "#d7cbe1"
     :medium "#4e2c6c" :on-medium "#ba98d8"
     :subtle "#372448" :on-subtle "#aa84ca"
     :border "#8247b5" :focus "#7c50a1"
     :distant-foreground "#b79bcf")
    (magenta
     :text "#d592c0" :strong "#943476" :on-strong "#e1c9d9"
     :medium "#60274f" :on-medium "#d590bf"
     :subtle "#422138" :on-subtle "#c67aae"
     :border "#a13e82" :focus "#95497d"
     :distant-foreground "#cc95bb")
    (rose
     :text "#d694ac" :strong "#983659" :on-strong "#e1cad2"
     :medium "#63283d" :on-medium "#d692ab"
     :subtle "#44212e" :on-subtle "#c77c98"
     :border "#a54065" :focus "#974b66"
     :distant-foreground "#cd97aa")
    (amber
     :text "#d29e2e" :strong "#6d5626" :on-strong "#d8cfba"
     :medium "#483b1d" :on-medium "#d19e2e"
     :subtle "#332b19" :on-subtle "#b88b28"
     :border "#78612f" :focus "#746239"
     :distant-foreground "#c2a35f"))
  "Contrast-checked accent palettes for a dark background.")

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
