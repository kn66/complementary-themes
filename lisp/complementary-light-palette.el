;;; complementary-light-palette.el --- Palettes and contrast math  -*- lexical-binding: t; -*-

;; Copyright (C) 2026
;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:

;; All color literals owned by the theme live in this file.  Face declarations
;; consume semantic tokens only.  Values are 8-bit sRGB.

;;; Code:

(require 'cl-lib)
(require 'color)

(defconst complementary-light-color-names
  '(red orange yellow green teal cyan blue indigo purple magenta rose amber)
  "Registered accent names accepted by the theme.")

(defconst complementary-light-neutral-palette
  '((background . "#ffffff")
    (surface . "#ffffff")
    (surface-raised . "#f4f4f1")
    (surface-sunken . "#ececea")
    (foreground . "#696968")
    (foreground-secondary . "#6b6b6a")
    (foreground-muted . "#696967")
    (foreground-faint . "#767674")
    (border . "#959593")
    (border-strong . "#888886")
    (divider . "#959593")
    (selection-neutral . "#e5e5e1")
    (inactive-background . "#eeeeeb")
    (inactive-foreground . "#6c6c6a")
    (distant-foreground . "#696969"))
  "Neutral colors shared by every accent selection.")

(defconst complementary-light-palettes
  '((red
     :text "#b04559" :strong "#b15d6e" :on-strong "#ffffff"
     :medium "#f7e7e9" :on-medium "#9a5664"
     :subtle "#fcf3f4" :on-subtle "#9f5d6a"
     :border "#cc7f8d" :focus "#c38390" :distant-foreground "#925a65")
    (orange
     :text "#9c5826" :strong "#9e6b47" :on-strong "#ffffff"
     :medium "#f7eadf" :on-medium "#8d6142"
     :subtle "#fcf4ed" :on-subtle "#91684a"
     :border "#bd8a61" :focus "#b48d71" :distant-foreground "#87644a")
    (yellow
     :text "#7d6722" :strong "#877540" :on-strong "#ffffff"
     :medium "#f4edcf" :on-medium "#786b3a"
     :subtle "#faf6e5" :on-subtle "#7d7041"
     :border "#a5945c" :focus "#a2946b" :distant-foreground "#776b41")
    (green
     :text "#35763d" :strong "#4f8256" :on-strong "#ffffff"
     :medium "#e2f1e4" :on-medium "#497550"
     :subtle "#eff8f0" :on-subtle "#507a56"
     :border "#6fa075" :focus "#769e7c" :distant-foreground "#4f7455")
    (teal
     :text "#14766d" :strong "#39827b" :on-strong "#ffffff"
     :medium "#dff1ee" :on-medium "#37766f"
     :subtle "#edf8f6" :on-subtle "#3e7b75"
     :border "#58a19a" :focus "#669f9a" :distant-foreground "#3f756f")
    (cyan
     :text "#157386" :strong "#3a808e" :on-strong "#ffffff"
     :medium "#dff0f3" :on-medium "#387380"
     :subtle "#edf7f8" :on-subtle "#3f7885"
     :border "#599fac" :focus "#679da8" :distant-foreground "#40737e")
    (blue
     :text "#2a6ca9" :strong "#477aa9" :on-strong "#ffffff"
     :medium "#e1edf7" :on-medium "#3f6e98"
     :subtle "#eff6fb" :on-subtle "#47749c"
     :border "#6799c6" :focus "#7199bd" :distant-foreground "#466e92")
    (indigo
     :text "#5765aa" :strong "#6973a9" :on-strong "#ffffff"
     :medium "#e7eaf7" :on-medium "#5d6797"
     :subtle "#f2f3fb" :on-subtle "#646d9b"
     :border "#8892c6" :focus "#8b93bc" :distant-foreground "#606891")
    (purple
     :text "#8157a5" :strong "#8a69a6" :on-strong "#ffffff"
     :medium "#eee7f5" :on-medium "#7c5d95"
     :subtle "#f7f2fa" :on-subtle "#81649a"
     :border "#a888c3" :focus "#a48bba" :distant-foreground "#795f8d")
    (magenta
     :text "#9a5083" :strong "#9d648b" :on-strong "#ffffff"
     :medium "#f5e6ef" :on-medium "#8c5a7d"
     :subtle "#fbf2f7" :on-subtle "#926182"
     :border "#bb84aa" :focus "#b388a6" :distant-foreground "#875d7a")
    (rose
     :text "#a44c6c" :strong "#a5637a" :on-strong "#ffffff"
     :medium "#f6e5eb" :on-medium "#93576c"
     :subtle "#fcf2f5" :on-subtle "#986073"
     :border "#c38299" :focus "#ba8698" :distant-foreground "#8d5b6d")
    (amber
     :text "#85641d" :strong "#8d733e" :on-strong "#ffffff"
     :medium "#f4ecd6" :on-medium "#7d6937"
     :subtle "#faf5e8" :on-subtle "#816f3e"
     :border "#ab9257" :focus "#a69369" :distant-foreground "#7a6940"))
  "Contrast-checked accent palettes for a light background.")

(defconst complementary-light-accent-pairs
  '((yellow . purple) (purple . yellow)
    (orange . blue) (blue . orange)
    (red . cyan) (cyan . red)
    (green . magenta) (magenta . green)
    (teal . rose) (rose . teal)
    (indigo . amber) (amber . indigo))
  "Registered UI-adjusted paired accents.")

(defconst complementary-light-required-neutral-tokens
  '(background surface surface-raised surface-sunken foreground
    foreground-secondary foreground-muted foreground-faint border
    border-strong divider selection-neutral inactive-background
    inactive-foreground distant-foreground))

(defconst complementary-light-required-accent-tokens
  '(:text :strong :on-strong :medium :on-medium :subtle :on-subtle
    :border :focus :distant-foreground))

(defconst complementary-light-contrast-pairs
  '((foreground background 4.5)
    (foreground-secondary surface-raised 4.5)
    (foreground-secondary surface-sunken 4.5)
    (foreground-faint background 4.5)
    (foreground-muted surface-sunken 4.5)
    (foreground region-background 4.5)
    (primary-text background 4.5)
    (secondary-text background 4.5)
    (primary-text surface-raised 4.5)
    (secondary-text surface-raised 4.5)
    (primary-text surface-sunken 4.5)
    (secondary-text surface-sunken 4.5)
    (foreground-muted background 4.5)
    (foreground primary-subtle 4.5)
    (primary-text primary-subtle 4.5)
    (secondary-text primary-subtle 4.5)
    (foreground secondary-subtle 4.5)
    (primary-text secondary-subtle 4.5)
    (secondary-text secondary-subtle 4.5)
    (foreground secondary-medium 4.5)
    (primary-text secondary-medium 4.5)
    (secondary-text secondary-medium 4.5)
    (foreground-muted secondary-medium 4.5)
    (foreground primary-medium 4.5)
    (primary-text primary-medium 4.5)
    (secondary-text primary-medium 4.5)
    (foreground-muted primary-medium 4.5)
    (foreground hl-line-background 4.5)
    (primary-text hl-line-background 4.5)
    (secondary-text hl-line-background 4.5)
    (foreground-muted hl-line-background 4.5)
    (foreground completion-background 4.5)
    (foreground match-background 4.5)
    (primary-on-strong primary-strong 4.5)
    (primary-on-state primary-state 4.5)
    (primary-state background 3.0)
    (primary-on-medium primary-medium 4.5)
    (primary-on-subtle primary-subtle 4.5)
    (inactive-foreground inactive-background 4.5)
    (secondary-on-strong secondary-strong 4.5)
    (secondary-on-state secondary-state 4.5)
    (secondary-state background 3.0)
    (secondary-on-medium secondary-medium 4.5)
    (secondary-on-subtle secondary-subtle 4.5)
    (border background 3.0)
    (border-strong surface-sunken 3.0)
    (divider background 3.0)
    (primary-border background 3.0)
    (primary-focus background 3.0)
    (secondary-border background 3.0))
  "Declared foreground/background pairs tested for every accent combination.")

(defconst complementary-light-overlap-scenarios
  '((region+isearch primary-on-state primary-state 4.5)
    (region+lazy-highlight foreground secondary-subtle 4.5)
    (region+match foreground primary-subtle 4.5)
    (hl-line+region foreground region-background 4.5)
    (diff+region foreground region-background 4.5)
    (completion+match foreground primary-subtle 4.5)
    (show-paren+region foreground region-background 4.5)
    (primary-syntax+region primary-text region-background 4.5)
    (secondary-syntax+region secondary-text region-background 4.5)
    (muted+region foreground-muted region-background 4.5))
  "Declared effective pairs for common overlapping face scenarios.")

(defun complementary-light-palette (name &optional noerror)
  "Return registered palette NAME.
Signal `user-error' unless NOERROR is non-nil when NAME is unknown."
  (or (cdr (assq name complementary-light-palettes))
      (unless noerror
        (user-error "Unknown complementary-light color: %S" name))))

(defun complementary-light-paired-accent (primary)
  "Return the registered paired accent for PRIMARY."
  (or (cdr (assq primary complementary-light-accent-pairs))
      (user-error "No registered paired accent for %S" primary)))

(defun complementary-light-resolve-secondary (primary secondary &optional startup)
  "Resolve SECONDARY for PRIMARY.
With STARTUP non-nil, warn and use safe defaults for invalid values."
  (let ((safe-primary (if (assq primary complementary-light-palettes)
                          primary
                        (if startup
                            (progn (display-warning
                                    'complementary-light
                                    (format "Unknown primary %S; using yellow" primary))
                                   'yellow)
                          (user-error "Unknown complementary-light color: %S"
                                      primary)))))
    (cond ((eq secondary 'auto)
           (complementary-light-paired-accent safe-primary))
          ((assq secondary complementary-light-palettes) secondary)
          (startup
           (display-warning 'complementary-light
                            (format "Unknown secondary %S; using paired accent"
                                    secondary))
           (complementary-light-paired-accent safe-primary))
          (t (user-error "Unknown complementary-light color: %S" secondary)))))

(defun complementary-light--accent-token (name token)
  "Resolve TOKEN in accent palette NAME."
  (or (plist-get (complementary-light-palette name) token)
      (error "Palette %S has no token %S" name token)))

(defun complementary-light--accent-state-token (name)
  "Return the salient state surface for accent NAME.
Light palettes use their dark strong surface.  Dark palettes, detected from
the dynamically bound neutral background, use their bright text color."
  (complementary-light--accent-token
   name
   (if (> (complementary-light-relative-luminance
           (cdr (assq 'background complementary-light-neutral-palette)))
          0.5)
       :strong
     :text)))

(defun complementary-light-token (token primary secondary)
  "Resolve semantic TOKEN using PRIMARY and SECONDARY accent names."
  (or (cdr (assq token complementary-light-neutral-palette))
      (let ((name (symbol-name token)))
        (pcase name
          ((or "primary-state" "secondary-state")
           (complementary-light--accent-state-token
            (if (string-prefix-p "primary-" name) primary secondary)))
          ((or "primary-on-state" "secondary-on-state")
           ;; The base surface is the most legible foreground on the adaptive
           ;; state color in both the light and dark palettes.
           (cdr (assq 'background complementary-light-neutral-palette)))
          ((rx bos "primary-" (let suffix (+ any)) eos)
           (complementary-light--accent-token
            primary (intern (concat ":" suffix))))
          ((rx bos "secondary-" (let suffix (+ any)) eos)
           (complementary-light--accent-token
            secondary (intern (concat ":" suffix))))
          ;; Highlight aliases deliberately share very pale surfaces so that
          ;; arbitrary syntax foregrounds remain readable when faces overlap.
          ("region-background" (complementary-light--accent-token secondary :medium))
          ("hl-line-background" (cdr (assq 'surface-raised complementary-light-neutral-palette)))
          ("completion-background" (complementary-light--accent-token secondary :subtle))
          ("match-background" (complementary-light--accent-token primary :subtle))
          (_ (error "Unknown complementary-light token: %S" token))))))

(defun complementary-light-valid-hex-p (value)
  "Return non-nil when VALUE is a six-digit sRGB hex string."
  (and (stringp value)
       (string-match-p "\\`#[[:xdigit:]]\\{6\\}\\'" value)))

(defun complementary-light--srgb-channel (byte)
  "Convert 8-bit sRGB BYTE to a linear channel."
  (let ((channel (/ byte 255.0)))
    (if (<= channel 0.04045)
        (/ channel 12.92)
      (expt (/ (+ channel 0.055) 1.055) 2.4))))

(defun complementary-light-relative-luminance (hex)
  "Return WCAG relative luminance for six-digit sRGB HEX."
  (unless (complementary-light-valid-hex-p hex)
    (error "Invalid six-digit sRGB color: %S" hex))
  (let ((red (string-to-number (substring hex 1 3) 16))
        (green (string-to-number (substring hex 3 5) 16))
        (blue (string-to-number (substring hex 5 7) 16)))
    (+ (* 0.2126 (complementary-light--srgb-channel red))
       (* 0.7152 (complementary-light--srgb-channel green))
       (* 0.0722 (complementary-light--srgb-channel blue)))))

(defun complementary-light-contrast-ratio (foreground background)
  "Return WCAG contrast ratio between FOREGROUND and BACKGROUND."
  (let* ((a (complementary-light-relative-luminance foreground))
         (b (complementary-light-relative-luminance background))
         (lighter (max a b))
         (darker (min a b)))
    (/ (+ lighter 0.05) (+ darker 0.05))))

(defconst complementary-light--xterm-256-colors
  (let* ((base '((0 0 0) (205 0 0) (0 205 0) (205 205 0)
                 (0 0 238) (205 0 205) (0 205 205) (229 229 229)
                 (127 127 127) (255 0 0) (0 255 0) (255 255 0)
                 (92 92 255) (255 0 255) (0 255 255) (255 255 255)))
         (levels '(0 95 135 175 215 255))
         (cube (cl-loop for red in levels append
                        (cl-loop for green in levels append
                                 (cl-loop for blue in levels
                                          collect (list red green blue)))))
         (grays (cl-loop for value from 8 to 238 by 10
                         collect (list value value value))))
    (append base cube grays))
  "The standard xterm-256 palette in the order registered by Emacs.")

(defvar complementary-light--xterm-256-color-cache
  (make-hash-table :test #'equal)
  "Memoized xterm-256 approximations for theme-owned sRGB colors.")

(defvar complementary-light--xterm-256-foreground-cache
  (make-hash-table :test #'equal)
  "Memoized contrast-safe xterm-256 foreground choices.")

(defun complementary-light--hex-rgb (hex)
  "Return the three 8-bit channels in six-digit sRGB HEX."
  (unless (complementary-light-valid-hex-p hex)
    (error "Invalid six-digit sRGB color: %S" hex))
  (list (string-to-number (substring hex 1 3) 16)
        (string-to-number (substring hex 3 5) 16)
        (string-to-number (substring hex 5 7) 16)))

(defun complementary-light--rgb-hex (rgb)
  "Return an sRGB hex string for three 8-bit channels in RGB."
  (apply #'format "#%02x%02x%02x" rgb))

(defun complementary-light--rgb-distance (first second)
  "Return squared Euclidean RGB distance between FIRST and SECOND."
  (cl-loop for a in first for b in second sum (expt (- a b) 2)))

(defun complementary-light--off-gray-angle (rgb)
  "Return RGB's angle from the gray diagonal, as used by Emacs TTY colors."
  (pcase-let ((`(,red ,green ,blue) rgb))
    (let ((magnitude
           (sqrt (* 3.0 (+ (* red red) (* green green) (* blue blue))))))
      (if (< magnitude 1.0)
          0.0
        (acos (max -1.0 (min 1.0 (/ (+ red green blue) magnitude))))))))

(defun complementary-light-xterm-256-color (hex)
  "Return the standard xterm-256 color to which Emacs maps sRGB HEX.
This mirrors `tty-color-approximate', including its preference for non-gray
colors when the requested color is sufficiently far from the gray diagonal."
  (or (gethash hex complementary-light--xterm-256-color-cache)
      (let* ((rgb (complementary-light--hex-rgb hex))
             (favor-non-gray
              (>= (complementary-light--off-gray-angle rgb) 0.065))
             (best-distance most-positive-fixnum)
             best)
        (dolist (candidate complementary-light--xterm-256-colors)
          (when (or (not favor-non-gray)
                    (not (= (nth 0 candidate)
                            (nth 1 candidate)
                            (nth 2 candidate))))
            (let ((distance
                   (complementary-light--rgb-distance rgb candidate)))
              (when (< distance best-distance)
                (setq best-distance distance
                      best candidate)))))
        (puthash hex (complementary-light--rgb-hex best)
                 complementary-light--xterm-256-color-cache))))

(defun complementary-light--xterm-256-safe-foreground
    (foreground background required)
  "Return an xterm-256-safe FOREGROUND for BACKGROUND and REQUIRED contrast.
Keep FOREGROUND when its quantized value passes.  Otherwise choose the closest
hue-preserving color from the standardized 240-color xterm extension; this
avoids depending on user-configurable ANSI base colors."
  (let ((key (list foreground background required)))
    (or (gethash key complementary-light--xterm-256-foreground-cache)
        (let* ((foreground-rgb (complementary-light--hex-rgb foreground))
               (quantized-foreground
                (complementary-light-xterm-256-color foreground))
               (quantized-background
                (complementary-light-xterm-256-color background))
               (result
                (if (>= (complementary-light-contrast-ratio
                         quantized-foreground quantized-background)
                        required)
                    foreground
                  (let ((favor-non-gray
                         (>= (complementary-light--off-gray-angle
                              foreground-rgb)
                             0.065))
                        (best-distance most-positive-fixnum)
                        best)
                    (dolist (candidate
                             (nthcdr 16 complementary-light--xterm-256-colors))
                      (when (and
                             (or (not favor-non-gray)
                                 (not (= (nth 0 candidate)
                                         (nth 1 candidate)
                                         (nth 2 candidate))))
                             (>= (complementary-light-contrast-ratio
                                  (complementary-light--rgb-hex candidate)
                                  quantized-background)
                                 required))
                        (let ((distance
                               (complementary-light--rgb-distance
                                foreground-rgb candidate)))
                          (when (< distance best-distance)
                            (setq best-distance distance
                                  best candidate)))))
                    (unless best
                      (error "No xterm-256 foreground reaches %.1f:1 for %s"
                             required background))
                    (complementary-light--rgb-hex best)))))
          (puthash key result
                   complementary-light--xterm-256-foreground-cache)))))

(defun complementary-light-terminal-adjust-attributes
    (attributes &optional required)
  "Return ATTRIBUTES with an xterm-256-safe explicit text pair.
Only an explicit foreground/background pair is changed.  REQUIRED defaults to
4.5, while attributes with only one color retain their original face topology."
  (let ((foreground (plist-get attributes :foreground))
        (background (plist-get attributes :background))
        (result (copy-tree attributes)))
    (when (and (complementary-light-valid-hex-p foreground)
               (complementary-light-valid-hex-p background))
      (setq result
            (plist-put
             result :foreground
             (complementary-light--xterm-256-safe-foreground
              foreground background (or required 4.5)))))
    result))

(defun complementary-light-validate-palettes ()
  "Return nil or signal an error describing the first palette defect."
  (dolist (token complementary-light-required-neutral-tokens)
    (unless (complementary-light-valid-hex-p
             (cdr (assq token complementary-light-neutral-palette)))
      (error "Missing or invalid neutral token: %S" token)))
  (dolist (name complementary-light-color-names)
    (let ((palette (complementary-light-palette name)))
      (dolist (token complementary-light-required-accent-tokens)
        (unless (complementary-light-valid-hex-p (plist-get palette token))
          (error "%S has missing or invalid token %S" name token)))))
  (dolist (pair complementary-light-accent-pairs)
    (unless (and (assq (car pair) complementary-light-palettes)
                 (assq (cdr pair) complementary-light-palettes)
                 (not (eq (car pair) (cdr pair)))
                 (eq (cdr (assq (cdr pair) complementary-light-accent-pairs))
                     (car pair)))
      (error "Invalid asymmetric paired accent: %S" pair)))
  nil)

(provide 'complementary-light-palette)
;;; complementary-light-palette.el ends here
