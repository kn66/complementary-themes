# complementary-themes

This package provides WCAG AA-calibrated light and dark themes for GNU Emacs. `complementary-light` uses a pure white background; `complementary-dark` uses a near-black neutral background. Both use gray neutrals plus exactly two registered accent families: primary and secondary. Most ordinary code remains neutral. Declarations and reserved syntax use the primary accent, while names, types, strings, and related constructs use the secondary accent. The themes change colors only, and only where the built-in `defface` already uses the corresponding color attribute. Bold, italic, underline, box, strike-through, inverse-video, height, width, inheritance, and extension behavior remain identical to the default `defface` specifications.

The secondary color is not intended to be a mathematically exact complementary color. It is a UI-adjusted paired accent chosen for legibility, distinction, and visual harmony on each background.

## Installation and usage

The supported distribution is a normal multi-file `package.el` archive. Build it and install the resulting versioned tar file:

```sh
make package
```

Then run `M-x package-install-file` and select `dist/complementary-themes-0.2.0.tar`. The archive contains `complementary-themes-pkg.el`, uses the directory layout required by `package.el`, and contains no symbolic links. During installation, `package.el` generates its normal package and theme autoload metadata (`theme-loaddefs.el` on Emacs 30); the generated package autoload adds the installed directory to `custom-theme-load-path`. No manually installed loader, symbolic link, or source-tree entry in `custom-theme-load-path` is required.

After package activation, the theme is visible to `load-theme` directly:

```elisp
(load-theme 'complementary-light t)
```

The package also provides a shared entry point for `use-package`:

```elisp
(use-package complementary-themes
  :load-path "~/.emacs.d/lisp/complementary-themes/"
  :config
  (setopt complementary-light-primary-color 'yellow
          complementary-light-secondary-color 'auto
          complementary-dark-primary-color 'yellow
          complementary-dark-secondary-color 'auto)
  (load-theme 'complementary-light t))
```

Use the dark counterpart with the same face policy and paired accents:

```elisp
(load-theme 'complementary-dark t)
```

The same installation can be performed non-interactively:

```elisp
(package-install-file "/path/to/complementary-themes-0.2.0.tar")

(setq complementary-light-primary-color 'yellow
      complementary-light-secondary-color 'auto)

(load-theme 'complementary-light t)
```

An explicit secondary color is also supported:

```elisp
(setq complementary-light-primary-color 'yellow
      complementary-light-secondary-color 'blue)
(load-theme 'complementary-light t)
```

Available color names are `red`, `orange`, `yellow`, `green`, `teal`, `cyan`, `blue`, `indigo`, `purple`, `magenta`, `rose`, and `amber`. Arbitrary HEX, lightness, or saturation input is not supported. Interactive commands signal `user-error` for an unknown name. When a stale or invalid value is encountered while loading an init file, the theme emits a warning and safely falls back to `yellow` and its registered paired accent.

The fixed `auto` mappings are symmetric:

| Primary | Secondary | Primary | Secondary |
|---|---|---|---|
| yellow | purple | orange | blue |
| red | cyan | green | magenta |
| teal | rose | indigo | amber |

Four interactive commands are provided:

- `M-x complementary-light-set-primary-color`
- `M-x complementary-light-set-secondary-color`
- `M-x complementary-light-refresh`
- `M-x complementary-light-preview`

The dark theme has independent accent settings and provides:

- `M-x complementary-dark-set-primary-color`
- `M-x complementary-dark-set-secondary-color`
- `M-x complementary-dark-refresh`

The corresponding variables are `complementary-dark-primary-color` and `complementary-dark-secondary-color`. Changing one theme does not change the other.

Color commands accept completion candidates only. If the theme is disabled, they change only the current setting. If it is enabled, they safely reapply the theme. Refresh replaces settings belonging to the same Custom Theme and removes obsolete face settings, so it does not accumulate duplicate face specs or duplicate entries in `custom-enabled-themes`. It does not disable other themes, and it verifies that their relative order and the `user` theme remain unchanged. Settings made by these commands affect only the current session and are not written to the Customize file.

Perfect visual composition with multiple themes is not guaranteed. Using `complementary-light` on its own is recommended so that precedence remains unambiguous. The theme nevertheless does not automatically disable other themes or modify the `user` theme through `custom-set-faces`.

## Palette and contrast

All theme-owned color literals are centralized in [complementary-light-palette.el](lisp/complementary-light-palette.el) and [complementary-dark-palette.el](lisp/complementary-dark-palette.el). Face declarations refer only to semantic tokens such as `background`, `foreground-muted`, `primary-text`, and `secondary-subtle`. Every accent palette provides `text`, `strong`, `on-strong`, `medium`, `on-medium`, `subtle`, `on-subtle`, `border`, `focus`, and `distant-foreground` tokens.

The theme uses WCAG 2.2 and WCAG2ICT as design references. Ordinary text targets 4.5:1 and important non-text boundaries target 3:1. Every foreground, border, focus, and distant-foreground role is calibrated to the lightest hue-preserving 8-bit sRGB candidate that stays within 0.06 of its applicable threshold in its most demanding declared pairing. Other valid pairings may have a higher ratio because one color is reused over several surfaces. This does not claim complete WCAG conformance across Emacs, fonts, terminals, operating systems, and every possible face overlap.

Relative luminance uses normalized 8-bit sRGB channels. For `c <= 0.04045`, the linear value is `c / 12.92`; otherwise it is `((c + 0.055) / 1.055) ^ 2.4`. Luminance coefficients are 0.2126, 0.7152, and 0.0722. Contrast is `(Llighter + 0.05) / (Ldarker + 0.05)`.

Tests validate body, secondary, muted, and faint text; accent text; strong/medium/subtle surfaces; neutral and accent borders; focus indicators; and `:distant-foreground` across all 144 primary/secondary combinations for both themes. They enforce both the AA lower bounds and the 0.06 calibration ceiling for each color role. Declared overlap scenarios cover region, hl-line, isearch, lazy-highlight, match, diff, completion, and show-paren faces. The light theme's lowest measured ratios are `4.5002:1` for text and `3.0005:1` for non-text; the dark theme's are `4.5009:1` and `3.0001:1`, respectively.

`:distant-foreground` is used on pale background-highlight faces such as region, search, completion, match, and hl-line. It provides a fallback when terminal color quantization makes the ordinary foreground too close to the background; it is not intended as an unconditional foreground override.

### Built-in color topology

The theme preserves the color topology of each built-in face. A face receives a theme foreground, background, or distant foreground only when its recorded default `defface` declares that same attribute. The check is also applied per display clause, so a face that uses only a background in a true-color light frame and only a foreground in a low-color fallback keeps that distinction.

For example, the built-in `org-block` face inherits `shadow` without declaring a background, so the theme does not register an `org-block` face spec and does not add a panel behind source blocks. `org-block-begin-line` and `org-block-end-line` likewise retain their normal inheritance. `diff-changed`, whose default declaration has no colors of its own, is preserved; `diff-added` and `diff-removed` retain the default display-dependent foreground/background structure while substituting registered accent tokens only at the corresponding positions.

## Non-color attribute preservation

The theme defines no independent non-color state grammar. Error, warning, success, disabled, added, removed, changed, and focus states retain the exact non-color behavior supplied by their default `defface` definitions. In particular, the theme does not add or remove bold, italic, underline, wave, box, strike-through, inverse-video, height, width, inheritance, or extension attributes.

| State | Theme-owned color family | Non-color representation |
|---|---|---|
| Error | Primary | Unchanged from the default face |
| Warning | Secondary | Unchanged from the default face |
| Success | Secondary | Unchanged from the default face |
| Info | Neutral / secondary | Unchanged from the default face |
| Disabled | Neutral | Unchanged from the default face |
| Deleted | Primary | Unchanged from the default diff face |
| Added | Secondary | Unchanged from the default diff face |
| Changed | Primary / secondary | Unchanged from the default diff face |
| Focus | Primary | Unchanged except for theme-owned colors |
| Secondary focus | Secondary | Unchanged except for theme-owned colors |

The face generator extracts `:family`, `:foundry`, `:width`, `:height`, `:weight`, `:slant`, `:underline`, `:overline`, `:strike-through`, `:box`, `:inverse-video`, `:extend`, and `:inherit` from the recorded `defface` specs for each display condition, then merges those attributes with theme-owned colors. Compound underline and box values preserve their style and line width while only embedded line colors may be replaced by palette tokens. `complementary-light-non-color-attribute-allowlist` is deliberately empty.

ERT compares both direct and inheritance-resolved effective attributes before and after applying the theme under the same `emacs -Q` display environment. Dedicated diff tests load `diff-mode` first and require exact equality for all protected direct and effective attributes. For compound line attributes, the general test normalizes only the embedded color while comparing the remaining structure. Any non-color difference fails the test. GUI and TTY snapshots are not treated as interchangeable expected values.

The active mode line uses the theme foreground on a raised neutral surface so colored status faces remain visible. `mode-line-buffer-id` deliberately does not set a foreground; it preserves the original bold weight while inheriting the appropriate active or inactive mode-line foreground.

## Meaning of complete face coverage

The coverage target consists of named faces defined by GNU Emacs itself and by standard libraries bundled with the target Emacs installation. Anonymous faces, direct overlay attributes, external packages, user Customize settings, colors inside images/SVG/icons, and direct colors supplied by external programs are outside the inventory scope.

Complete coverage does not mean assigning colors to every face. It means recording every discovered named face in exactly one of these categories:

- `themed`: declares individual theme color tokens
- `inherit`: intentionally uses the original inheritance chain
- `alias`: preserves the face alias relationship
- `preserve`: intentionally retains original colors and attributes, with a reason
- `external-semantic`: preserves colors whose meaning belongs to an external protocol
- `excluded`: excluded for a documented reason
- `unavailable`: exists in another supported Emacs version but not the current environment

The reviewed Emacs 30.2/GNU/Linux baseline is [emacs-30.el](inventory/emacs-30.el), while [current-generated.el](inventory/current-generated.el) contains the most recent generated inventory. The current baseline contains 1,171 faces: 94 `themed`, 532 `inherit`, 12 `alias`, 494 `preserve`, 39 `external-semantic`, 0 `excluded`, and 0 unclassified. The 94 themed faces are maintained as searchable, face-specific declarations rather than being painted by a single blanket rule.

### How the inventory is collected

The generator combines:

1. `face-list` immediately after starting `emacs -Q`
2. The 1,652 `.el` and `.el.gz` files below `lisp-directory`
3. Static Emacs Lisp reader extraction of `defface`, `custom-declare-face`, `define-obsolete-face-alias`, and face-alias `put` forms
4. `face-defface-spec`, symbol `face-alias` properties, and source-file provenance

The generator does not unconditionally `require` every standard library, avoiding network, GUI, process, and user-configuration side effects. It records source file, library, line, default spec, startup-loaded status, alias target, and discovery method. Metadata also includes bundled packages, `load-path`, source format counts, display capabilities, and daemon capabilities.

```sh
make inventory
make test-faces
```

To update for a new Emacs version:

1. Run `make inventory`.
2. Compare `inventory/current-generated.el` with the reviewed version baseline.
3. Inspect each new face's library and `defface` declaration.
4. Explicitly assign `themed`, `inherit`, `alias`, `preserve`, `external-semantic`, or `excluded`.
5. For a themed face, assign semantic tokens individually.
6. Update the version baseline only after review.
7. Run the complete test suite and regenerate reports.

A face absent from the reviewed baseline causes `test-faces` to fail with the face name. New faces are not automatically assigned to `default` or silently painted neutral.

Org, Transient, use-package, and similar libraries are included in the built-in inventory only when they are bundled with the target Emacs. External-package faces remain outside that inventory count, but `lisp/complementary-light-packages.el` supplies color-only rules for the packages used by the companion `init.org`. Packages such as Consult, Marginalia, Embark, Eglot, and which-key already inherit the themed Emacs faces. The separate module replaces independent colors in Avy, Corfu, Denote, diff-hl, Magit/Transient, DDSKK, Tempel, treesit-fold, vundo, wgrep, and cognitive-complexity while preserving package-owned non-color attributes.

## ANSI and external colors

Named faces managed by the theme follow the neutral-plus-two-accents principle. ANSI escape sequences, images, SVG content, and colors directly supplied by external programs are outside the two-accent restriction so that their meaning is preserved.

Named faces such as `ansi-color-*`, `term-color-*`, and `xterm-color-*` are still recorded in the inventory and classified as `external-semantic`. Quantizing external red, yellow, or green values into two accents could destroy protocol-level failure, warning, or success meanings.

## Preview

`M-x complementary-light-preview` displays body, secondary, muted, and faint text; bold, italic, underline, wave, box, and strike-through samples; links and semantic states; selections and search matches; line numbers; mode/header/tab lines; tooltip and completion faces; diff/ediff samples; Font Lock faces; short Emacs Lisp, HTML, CSS, JavaScript, JSON, shell, and Org examples; every token from both active accent palettes; declared contrast ratios; and the current display color count.

Inside the preview, `n` and `p` cycle local paired-accent samples without changing global variables or Customize settings. `g` redraws the buffer and `q` quits.

## Display environments

Face specs provide three levels:

- GUI true color: `class color`, `min-colors 257`; precise sRGB HEX colors are the primary target.
- Color terminals: `class color`, `min-colors 16`; Emacs and the terminal quantize colors to the nearest available values while retaining default non-color attributes.
- Monochrome: `class mono`; original inheritance, bold, italic, underline, box, inverse video, and other default attributes take precedence over color reproduction.

The inventory environment used Emacs 30.2 build 1 on `gnu/linux` with a pgtk build. Its batch baseline had `window-system=nil` and `display-color-cells=0`; the host exposed Wayland/X display variables and `TERM=xterm-256color`. Each theme in the current build registers the same built-in face settings plus package-specific settings; named-daemon loading, refresh, and disable were tested. A real TTY could not be measured because the execution container could not open `/dev/tty`, and the GUI launch probe timed out. Use `complementary-light` for light backgrounds and `complementary-dark` for dark backgrounds.

In daemon mode, Custom Theme settings become new-frame defaults and therefore apply to frames created later. When GUI and TTY frames coexist, each frame selects its own display clause. The theme does not reload Customize data or call `custom-set-faces` when a new frame is created.

## Tests, compilation, and reports

```sh
make test
make test-load
make test-palette
make test-contrast
make test-faces
make test-attributes
make test-refresh
make test-terminal
make test-dark
make test-package
make compile
make package
make inventory
make reports
make clean
```

Tests use `emacs -Q --batch` wherever possible. `make compile` byte-compiles the helper modules and checks the theme source for compiler warnings. Source `.el` files are authoritative; distribution does not require `.elc` files.

`make test-package` installs the generated tar into an isolated temporary `package-user-dir`, verifies that no installed file is a symbolic link, checks that package-generated theme metadata exposes the theme to `custom-available-themes`, and loads, enables, and disables the theme without adding a source-tree path to `custom-theme-load-path`.

`make reports` generates:

- `reports/palette-contrast.json`: every palette, overlap scenario, measured ratio, and requirement
- `reports/face-coverage.json`: face, provenance, classification, target, token, and reason
- `reports/non-color-attribute-diff.json`: display environment, allowlist, and unexpected differences
- `reports/display-fallbacks.json`: true-color, terminal, and monochrome policy
- `reports/theme-summary.json`: version, classification counts, minimum ratio, and registered spec count

## Known limitations

- The measured inventory and attribute baseline are from Emacs 30.2. The code structure targets Emacs 29 and later, but an Emacs 29-specific inventory has not been generated or tested in this environment.
- Automated image comparison for protanopia, deuteranopia, tritanopia, low saturation, and grayscale is not used as a pass/fail criterion. The theme instead combines contrast and terminal-fallback tests with the distinctions already present in the default faces.
- Actual terminal quantization depends on the terminal emulator, `TERM`, and terminfo. The 16-color selector syntax and safe non-color fallback are tested, but rendered colors cannot be guaranteed for every terminal.
- Unlisted external-package faces, anonymous faces, images, SVG content, and direct ANSI colors remain outside the duotone restriction.
- Complete visual composition with other themes, arbitrary user face overrides, and font-specific line rendering is outside the guarantee.

## File layout

- `complementary-light-theme.el`, `complementary-dark-theme.el`: theme declarations, safe helper loading, and face registration
- `complementary-themes.el`: shared `use-package` and `require` entry point
- `complementary-light.el`, `complementary-dark.el`: independent Custom variables, interactive color changes, and idempotent refresh
- `complementary-themes-pkg.el`: `package.el` descriptor for the multi-file archive
- `lisp/complementary-light-palette.el`: light neutrals, accents, paired accents, and sRGB contrast calculations
- `lisp/complementary-dark-palette.el`: independently calibrated dark neutrals and accents
- `lisp/complementary-light-faces.el`: complete classification, per-face rules, attribute preservation, and display spec generation
- `lisp/complementary-light-packages.el`: color-only support for package faces used by `init.org`
- `lisp/complementary-light-preview.el`: preview buffer
- `tools/complementary-light-generate-faces.el`: reader-based built-in face inventory
- `tools/complementary-light-generate-reports.el`: JSON audit reports
- `inventory/`: reviewed version baseline and latest generated inventory
- `test/`: ERT suites for lifecycle, palette, contrast, coverage, attributes, refresh, and terminal fallback

## License

GPL-3.0-or-later
