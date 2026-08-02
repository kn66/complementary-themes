EMACS ?= emacs
PACKAGE_VERSION = 0.2.0
PACKAGE_TAR = dist/complementary-themes-$(PACKAGE_VERSION).tar
PACKAGE_FILES = complementary-themes-pkg.el complementary-themes.el \
	complementary-light-theme.el \
	complementary-light.el complementary-dark-theme.el complementary-dark.el \
	README.org \
	docs/palettes/accent-pairs.svg \
	docs/palettes/complementary-light.svg \
	docs/palettes/complementary-dark.svg \
	lisp/complementary-light-palette.el \
	lisp/complementary-dark-palette.el \
	lisp/complementary-light-faces.el \
	lisp/complementary-light-packages.el \
	lisp/complementary-light-preview.el \
	inventory/emacs-30.el
ELFLAGS = -Q --batch -L . -L lisp -L tools -L test
HELPER = -l test/complementary-light-test-helper.el
TESTS = test/complementary-light-load-test.el \
	test/complementary-light-palette-test.el \
	test/complementary-light-contrast-test.el \
	test/complementary-light-faces-test.el \
	test/complementary-light-packages-test.el \
	test/complementary-light-attributes-test.el \
	test/complementary-light-refresh-test.el \
	test/complementary-light-terminal-test.el \
	test/complementary-light-reports-test.el \
	test/complementary-dark-test.el \
	test/complementary-themes-screenshot-test.el

SCREENSHOT_DIR ?= Screenshots
SCREENSHOT_GEOMETRY ?= maximized
SCREENSHOT_FONT ?= Monospace-12

.PHONY: test test-package test-load test-palette test-contrast test-faces test-attributes test-refresh test-terminal test-dark test-screenshots screenshots compile package inventory reports palettes clean

test: package
	$(EMACS) $(ELFLAGS) $(HELPER) $(addprefix -l ,$(TESTS)) -f ert-run-tests-batch-and-exit
	COMPLEMENTARY_THEMES_PACKAGE_TAR=$(abspath $(PACKAGE_TAR)) $(EMACS) -Q --batch -L test -l test/complementary-themes-package-test.el -f ert-run-tests-batch-and-exit

test-package: package
	COMPLEMENTARY_THEMES_PACKAGE_TAR=$(abspath $(PACKAGE_TAR)) $(EMACS) -Q --batch -L test -l test/complementary-themes-package-test.el -f ert-run-tests-batch-and-exit

test-load:
	$(EMACS) $(ELFLAGS) $(HELPER) -l test/complementary-light-load-test.el -f ert-run-tests-batch-and-exit

test-palette:
	$(EMACS) $(ELFLAGS) $(HELPER) -l test/complementary-light-palette-test.el -f ert-run-tests-batch-and-exit

test-contrast:
	$(EMACS) $(ELFLAGS) $(HELPER) -l test/complementary-light-contrast-test.el -f ert-run-tests-batch-and-exit

test-faces:
	$(EMACS) $(ELFLAGS) $(HELPER) -l test/complementary-light-faces-test.el -f ert-run-tests-batch-and-exit

test-attributes:
	$(EMACS) $(ELFLAGS) $(HELPER) -l test/complementary-light-attributes-test.el -f ert-run-tests-batch-and-exit

test-refresh:
	$(EMACS) $(ELFLAGS) $(HELPER) -l test/complementary-light-refresh-test.el -f ert-run-tests-batch-and-exit

test-terminal:
	$(EMACS) $(ELFLAGS) $(HELPER) -l test/complementary-light-terminal-test.el -f ert-run-tests-batch-and-exit

test-dark:
	$(EMACS) $(ELFLAGS) $(HELPER) -l test/complementary-dark-test.el -f ert-run-tests-batch-and-exit

test-screenshots:
	$(EMACS) $(ELFLAGS) -l test/complementary-themes-screenshot-test.el -f ert-run-tests-batch-and-exit

screenshots:
	COMPLEMENTARY_THEMES_SCREENSHOT_DIR="$(abspath $(SCREENSHOT_DIR))" \
	COMPLEMENTARY_THEMES_SCREENSHOT_GEOMETRY="$(SCREENSHOT_GEOMETRY)" \
	COMPLEMENTARY_THEMES_SCREENSHOT_FONT="$(SCREENSHOT_FONT)" \
	$(EMACS) -Q --no-splash -L . -L lisp -L tools \
	-l tools/complementary-themes-capture-screenshots.el \
	-f complementary-themes-capture-screenshots-cli

compile:
	$(EMACS) $(ELFLAGS) -f batch-byte-compile complementary-light.el complementary-themes.el lisp/complementary-light-palette.el lisp/complementary-dark-palette.el lisp/complementary-light-faces.el lisp/complementary-light-packages.el lisp/complementary-light-preview.el tools/complementary-light-generate-faces.el tools/complementary-light-generate-reports.el tools/complementary-themes-generate-palettes.el tools/complementary-themes-capture-screenshots.el
	$(EMACS) $(ELFLAGS) -f batch-byte-compile complementary-light-theme.el complementary-dark.el complementary-dark-theme.el

package:
	mkdir -p dist
	tar --format=ustar -cf $(PACKAGE_TAR) --transform='s,^,complementary-themes-$(PACKAGE_VERSION)/,' $(PACKAGE_FILES)

inventory:
	$(EMACS) $(ELFLAGS) -l tools/complementary-light-generate-faces.el --eval '(complementary-light-inventory-write (expand-file-name "inventory/current-generated.el" default-directory))'
	@echo "Review current-generated.el against inventory/emacs-30.el; new faces intentionally fail make test-faces until the baseline and rules are updated."

reports:
	$(EMACS) $(ELFLAGS) -l tools/complementary-light-generate-reports.el --eval '(complementary-light-report-generate (expand-file-name "reports" default-directory))'

palettes:
	$(EMACS) $(ELFLAGS) -l tools/complementary-themes-generate-palettes.el --eval '(complementary-themes-generate-palette-svgs (expand-file-name "docs/palettes" default-directory))'

clean:
	find . -name '*.elc' -type f -delete
	$(RM) $(PACKAGE_TAR)
