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
    (foreground . "#b0b0b0")
    (foreground-secondary . "#929292")
    (foreground-muted . "#b0b0b0")
    (foreground-faint . "#888888")
    (border . "#696969")
    (border-strong . "#6d6d6d")
    (divider . "#696969")
    (selection-neutral . "#30302f")
    (inactive-background . "#171717")
    (inactive-foreground . "#8f8f8f")
    (cursor . "#ffffff")
    (distant-foreground . "#b0b0b0"))
  "Neutral colors used by `complementary-dark'.")

(defconst complementary-dark-palettes
  '((red
     :text "#dba0aa" :strong "#9b3649" :on-strong "#e8d7da"
     :medium "#642934" :on-medium "#daa0aa"
     :subtle "#442228" :on-subtle "#cf8793"
     :border "#aa495b" :focus "#9d5260"
     :distant-foreground "#d2a3ab")
    (orange
     :text "#dea378" :strong "#7d4f2c" :on-strong "#e5d9cf"
     :medium "#523621" :on-medium "#dea376"
     :subtle "#39291c" :on-subtle "#d58a52"
     :border "#8d5f3c" :focus "#856246"
     :distant-foreground "#d0a789")
    (yellow
     :text "#cbad4b" :strong "#685824" :on-strong "#e0dbc8"
     :medium "#453c1c" :on-medium "#cbad4b"
     :subtle "#322c18" :on-subtle "#b4993f"
     :border "#796834" :focus "#75693e"
     :distant-foreground "#c2ae70")
    (green
     :text "#61c46d" :strong "#24662c" :on-strong "#c8e1cb"
     :medium "#1c4521" :on-medium "#61c46d"
     :subtle "#18321b" :on-subtle "#57ae61"
     :border "#34773c" :focus "#3d7544"
     :distant-foreground "#7bbf83")
    (teal
     :text "#3bc3b5" :strong "#23635d" :on-strong "#c8e0dd"
     :medium "#1b433f" :on-medium "#3bc3b5"
     :subtle "#18302e" :on-subtle "#2faca0"
     :border "#33736c" :focus "#3b726c"
     :distant-foreground "#55c1b6")
    (cyan
     :text "#3bbfd9" :strong "#26616c" :on-strong "#cbdee1"
     :medium "#1d4148" :on-medium "#3bbed7"
     :subtle "#1a2f34" :on-subtle "#31a9c0"
     :border "#36717c" :focus "#407079"
     :distant-foreground "#63bbcc")
    (blue
     :text "#84b5e0" :strong "#2f5d86" :on-strong "#d3dde6"
     :medium "#243e57" :on-medium "#82b4e0"
     :subtle "#1e2e3c" :on-subtle "#63a1d8"
     :border "#3f6d95" :focus "#496c8c"
     :distant-foreground "#8fb3d2")
    (indigo
     :text "#a4aedc" :strong "#3e51af" :on-strong "#d6dae8"
     :medium "#2d386e" :on-medium "#a3addc"
     :subtle "#242a49" :on-subtle "#8d98ce"
     :border "#5162bb" :focus "#5765a6"
     :distant-foreground "#a5add4")
    (purple
     :text "#c2a4dc" :strong "#773ca9" :on-strong "#e0d7e8"
     :medium "#4e2c6c" :on-medium "#c1a3dc"
     :subtle "#372448" :on-subtle "#b08dce"
     :border "#874eb8" :focus "#8157a4"
     :distant-foreground "#bea5d4")
    (magenta
     :text "#d99ec7" :strong "#943476" :on-strong "#e8d6e2"
     :medium "#60274f" :on-medium "#d99cc6"
     :subtle "#422138" :on-subtle "#cb85b4"
     :border "#a54687" :focus "#995082"
     :distant-foreground "#d1a0c2")
    (rose
     :text "#daa0b5" :strong "#983659" :on-strong "#e8d6dc"
     :medium "#63283d" :on-medium "#da9eb4"
     :subtle "#44212e" :on-subtle "#cc87a0"
     :border "#a9486b" :focus "#9b526c"
     :distant-foreground "#d2a2b3")
    (amber
     :text "#d7a945" :strong "#6d5626" :on-strong "#e1dac9"
     :medium "#483b1d" :on-medium "#d6a945"
     :subtle "#332b19" :on-subtle "#be953a"
     :border "#7c6635" :focus "#78673f"
     :distant-foreground "#c8ad70"))
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
