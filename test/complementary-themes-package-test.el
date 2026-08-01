;;; complementary-themes-package-test.el --- package.el installation tests  -*- lexical-binding: t; -*-

(require 'cl-lib)
(require 'ert)
(require 'package)

(ert-deftest complementary-themes-package-installs-without-links ()
  (let* ((archive (getenv "COMPLEMENTARY_THEMES_PACKAGE_TAR"))
         (temporary-root
          (make-temp-file "complementary-themes-package-test-" t))
         (user-emacs-directory (file-name-as-directory temporary-root))
         (package-user-dir (expand-file-name "elpa" temporary-root))
         (custom-file (expand-file-name "custom.el" temporary-root))
         (package-native-compile nil)
         (package-quickstart nil)
         (package-quickstart-file
          (expand-file-name "package-quickstart.el" temporary-root))
         (package-alist nil)
         (package-activated-list nil)
         (package-selected-packages nil)
         (custom-theme-directory
          (expand-file-name "themes" temporary-root))
         (custom-theme-load-path '(custom-theme-directory t)))
    (unwind-protect
        (progn
          (should (and archive (file-regular-p archive)))
          (package-install-file archive)
          (let* ((descriptor (cadr (assq 'complementary-themes package-alist)))
                 (directory (and descriptor (package-desc-dir descriptor))))
            (should descriptor)
            (should (file-directory-p directory))
            (should-not
             (cl-some #'file-symlink-p
                      (directory-files-recursively directory "." t)))
            (should
             (cl-some (lambda (entry)
                        (and (stringp entry)
                             (file-equal-p entry directory)))
                      custom-theme-load-path))
            (should (memq 'complementary-light
                          (custom-available-themes)))
            (should (memq 'complementary-dark
                          (custom-available-themes)))
            (should (require 'complementary-themes nil t))
            (should (featurep 'complementary-light))
            (should (featurep 'complementary-dark))
            (load-theme 'complementary-light t)
            (should (custom-theme-enabled-p 'complementary-light))
            (should-not
             (assq 'complementary-light (get 'org-block 'theme-face)))
            (disable-theme 'complementary-light)
            (load-theme 'complementary-dark t)
            (should (custom-theme-enabled-p 'complementary-dark))
            (disable-theme 'complementary-dark)))
      (when (custom-theme-enabled-p 'complementary-light)
        (disable-theme 'complementary-light))
      (when (custom-theme-enabled-p 'complementary-dark)
        (disable-theme 'complementary-dark))
      (delete-directory temporary-root t))))

(provide 'complementary-themes-package-test)
;;; complementary-themes-package-test.el ends here
