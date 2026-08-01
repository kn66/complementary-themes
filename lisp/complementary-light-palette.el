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
    (foreground . "#626262")
    (foreground-secondary . "#646464")
    (foreground-muted . "#626261")
    (foreground-faint . "#6f6f6e")
    (border . "#8e8e8d")
    (border-strong . "#828281")
    (divider . "#8e8e8d")
    (selection-neutral . "#ececea")
    (inactive-background . "#eeeeeb")
    (inactive-foreground . "#656564")
    (cursor . "#000000")
    (distant-foreground . "#626262"))
  "Neutral colors shared by every accent selection.")

(defconst complementary-light-palettes
  '((red
     :text "#a54053" :strong "#a65767" :on-strong "#ffffff"
     :medium "#f7e7e9" :on-medium "#90505e"
     :subtle "#fcf3f4" :on-subtle "#965764"
     :border "#c37a87" :focus "#bb7d8a" :distant-foreground "#89545f")
    (orange
     :text "#925224" :strong "#946443" :on-strong "#ffffff"
     :medium "#f7eadf" :on-medium "#845b3e"
     :subtle "#fcf4ed" :on-subtle "#886145"
     :border "#b5845d" :focus "#ad876c" :distant-foreground "#7e5d45")
    (yellow
     :text "#756020" :strong "#7f6e3c" :on-strong "#ffffff"
     :medium "#f4edcf" :on-medium "#706436"
     :subtle "#faf6e5" :on-subtle "#76693d"
     :border "#9e8d58" :focus "#9b8e67" :distant-foreground "#6f643d")
    (green
     :text "#326e39" :strong "#4a7a51" :on-strong "#ffffff"
     :medium "#e2f1e4" :on-medium "#456e4b"
     :subtle "#eff8f0" :on-subtle "#4b7351"
     :border "#6a9970" :focus "#719877" :distant-foreground "#4a6c50")
    (teal
     :text "#136e66" :strong "#367a74" :on-strong "#ffffff"
     :medium "#dff1ee" :on-medium "#346e68"
     :subtle "#edf8f6" :on-subtle "#3a736e"
     :border "#549a94" :focus "#629894" :distant-foreground "#3b6d68")
    (cyan
     :text "#146b7d" :strong "#377886" :on-strong "#ffffff"
     :medium "#dff0f3" :on-medium "#356c79"
     :subtle "#edf7f8" :on-subtle "#3b717e"
     :border "#5598a5" :focus "#6396a1" :distant-foreground "#3c6b76")
    (blue
     :text "#27659f" :strong "#4373a0" :on-strong "#ffffff"
     :medium "#e1edf7" :on-medium "#3b678f"
     :subtle "#eff6fb" :on-subtle "#436d93"
     :border "#6393bf" :focus "#6c92b5" :distant-foreground "#416789")
    (indigo
     :text "#515e9f" :strong "#636c9f" :on-strong "#ffffff"
     :medium "#e7eaf7" :on-medium "#57618d"
     :subtle "#f2f3fb" :on-subtle "#5e6692"
     :border "#838cbe" :focus "#858cb4" :distant-foreground "#5a6188")
    (purple
     :text "#79519b" :strong "#81639c" :on-strong "#ffffff"
     :medium "#eee7f5" :on-medium "#73578b"
     :subtle "#f7f2fa" :on-subtle "#795d90"
     :border "#a182bb" :focus "#9e85b3" :distant-foreground "#715984")
    (magenta
     :text "#8f4b7a" :strong "#945e83" :on-strong "#ffffff"
     :medium "#f5e6ef" :on-medium "#825475"
     :subtle "#fbf2f7" :on-subtle "#885b7a"
     :border "#b37ea3" :focus "#ac829f" :distant-foreground "#7e5771")
    (rose
     :text "#9a4765" :strong "#9a5d72" :on-strong "#ffffff"
     :medium "#f6e5eb" :on-medium "#8a5165"
     :subtle "#fcf2f5" :on-subtle "#8e5a6c"
     :border "#bb7c93" :focus "#b28192" :distant-foreground "#835566")
    (amber
     :text "#7c5d1b" :strong "#846c3a" :on-strong "#ffffff"
     :medium "#f4ecd6" :on-medium "#756234"
     :subtle "#faf5e8" :on-subtle "#79683a"
     :border "#a48c54" :focus "#9f8c64" :distant-foreground "#72623c"))
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
    inactive-foreground cursor distant-foreground))

(defconst complementary-light-cursor-background-tokens
  '(background surface-raised surface-sunken region-background
    hl-line-background completion-background match-background
    primary-medium primary-subtle secondary-medium secondary-subtle)
  "Surfaces on which the single Emacs cursor color must remain visible.")

(defconst complementary-light-required-accent-tokens
  '(:text :strong :on-strong :medium :on-medium :subtle :on-subtle
    :border :focus :distant-foreground))

(defconst complementary-light-wcag-text-contrast 4.5
  "WCAG AA minimum contrast ratio for normal text.")

(defconst complementary-light-wcag-non-text-contrast 3.0
  "WCAG minimum contrast ratio for meaningful non-text graphics.")

(defconst complementary-light-text-contrast-target 5.0
  "Theme design target for text contrast, including a safety margin.")

(defconst complementary-light-non-text-contrast-target 3.25
  "Theme design target for non-text contrast, including a safety margin.")

(defconst complementary-light-contrast-pairs
  `((foreground background ,complementary-light-text-contrast-target)
    (foreground-secondary surface-raised ,complementary-light-text-contrast-target)
    (foreground-secondary surface-sunken ,complementary-light-text-contrast-target)
    (foreground-faint background ,complementary-light-text-contrast-target)
    (foreground-muted surface-sunken ,complementary-light-text-contrast-target)
    (foreground region-background ,complementary-light-text-contrast-target)
    (primary-text background ,complementary-light-text-contrast-target)
    (secondary-text background ,complementary-light-text-contrast-target)
    (primary-text surface-raised ,complementary-light-text-contrast-target)
    (secondary-text surface-raised ,complementary-light-text-contrast-target)
    (primary-text surface-sunken ,complementary-light-text-contrast-target)
    (secondary-text surface-sunken ,complementary-light-text-contrast-target)
    (foreground-muted background ,complementary-light-text-contrast-target)
    (foreground primary-subtle ,complementary-light-text-contrast-target)
    (primary-text primary-subtle ,complementary-light-text-contrast-target)
    (secondary-text primary-subtle ,complementary-light-text-contrast-target)
    (foreground secondary-subtle ,complementary-light-text-contrast-target)
    (primary-text secondary-subtle ,complementary-light-text-contrast-target)
    (secondary-text secondary-subtle ,complementary-light-text-contrast-target)
    (foreground secondary-medium ,complementary-light-text-contrast-target)
    (primary-text secondary-medium ,complementary-light-text-contrast-target)
    (secondary-text secondary-medium ,complementary-light-text-contrast-target)
    (foreground-muted secondary-medium ,complementary-light-text-contrast-target)
    (foreground primary-medium ,complementary-light-text-contrast-target)
    (primary-text primary-medium ,complementary-light-text-contrast-target)
    (secondary-text primary-medium ,complementary-light-text-contrast-target)
    (foreground-muted primary-medium ,complementary-light-text-contrast-target)
    (foreground hl-line-background ,complementary-light-text-contrast-target)
    (primary-text hl-line-background ,complementary-light-text-contrast-target)
    (secondary-text hl-line-background ,complementary-light-text-contrast-target)
    (foreground-muted hl-line-background ,complementary-light-text-contrast-target)
    (foreground completion-background ,complementary-light-text-contrast-target)
    (foreground match-background ,complementary-light-text-contrast-target)
    (primary-on-strong primary-strong ,complementary-light-text-contrast-target)
    (primary-on-state primary-state ,complementary-light-text-contrast-target)
    (primary-state background ,complementary-light-non-text-contrast-target)
    (primary-on-medium primary-medium ,complementary-light-text-contrast-target)
    (primary-on-subtle primary-subtle ,complementary-light-text-contrast-target)
    (inactive-foreground inactive-background ,complementary-light-text-contrast-target)
    (secondary-on-strong secondary-strong ,complementary-light-text-contrast-target)
    (secondary-on-state secondary-state ,complementary-light-text-contrast-target)
    (secondary-state background ,complementary-light-non-text-contrast-target)
    (secondary-on-medium secondary-medium ,complementary-light-text-contrast-target)
    (secondary-on-subtle secondary-subtle ,complementary-light-text-contrast-target)
    (border background ,complementary-light-non-text-contrast-target)
    (border-strong surface-sunken ,complementary-light-non-text-contrast-target)
    (divider background ,complementary-light-non-text-contrast-target)
    (primary-border background ,complementary-light-non-text-contrast-target)
    (primary-focus background ,complementary-light-non-text-contrast-target)
    (secondary-border background ,complementary-light-non-text-contrast-target))
  "Declared foreground/background pairs tested for every accent combination.")

(defconst complementary-light-overlap-scenarios
  `((region+isearch primary-on-state primary-state ,complementary-light-text-contrast-target)
    (region+lazy-highlight foreground secondary-subtle ,complementary-light-text-contrast-target)
    (region+match foreground primary-subtle ,complementary-light-text-contrast-target)
    (hl-line+region foreground region-background ,complementary-light-text-contrast-target)
    (diff+region foreground region-background ,complementary-light-text-contrast-target)
    (completion+match foreground primary-subtle ,complementary-light-text-contrast-target)
    (show-paren+region foreground region-background ,complementary-light-text-contrast-target)
    (primary-syntax+region primary-text region-background ,complementary-light-text-contrast-target)
    (secondary-syntax+region secondary-text region-background ,complementary-light-text-contrast-target)
    (muted+region foreground-muted region-background ,complementary-light-text-contrast-target))
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
          ((and (assq secondary complementary-light-palettes)
                (not (eq secondary safe-primary)))
           secondary)
          ((eq secondary safe-primary)
           (if startup
               (progn
                 (display-warning
                  'complementary-light
                  (format "Secondary %S matches primary; using paired accent"
                          secondary))
                 (complementary-light-paired-accent safe-primary))
             (user-error "Primary and secondary accents must be distinct: %S"
                         safe-primary)))
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
the WCAG text minimum because some xterm-256 backgrounds cannot reach the
true-color design target.  Attributes with only one color retain their original
face topology."
  (let ((foreground (plist-get attributes :foreground))
        (background (plist-get attributes :background))
        (result (copy-tree attributes)))
    (when (and (complementary-light-valid-hex-p foreground)
               (complementary-light-valid-hex-p background))
      (setq result
            (plist-put
             result :foreground
             (complementary-light--xterm-256-safe-foreground
              foreground background
              (or required complementary-light-wcag-text-contrast)))))
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
