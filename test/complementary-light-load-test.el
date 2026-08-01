;;; complementary-light-load-test.el --- Theme lifecycle tests  -*- lexical-binding: t; -*-

(require 'complementary-light-test-helper)

(ert-deftest complementary-light-load-enable-disable-repeat ()
  (let ((before (face-attribute 'default :foreground nil nil)))
    (unwind-protect
        (progn
          (load-theme 'complementary-light t)
          (should (custom-theme-enabled-p 'complementary-light))
          (disable-theme 'complementary-light)
          (should-not (custom-theme-enabled-p 'complementary-light))
          (should (equal before (face-attribute 'default :foreground nil nil)))
          (load-theme 'complementary-light t)
          (disable-theme 'complementary-light)
          (load-theme 'complementary-light t)
          (should (= 1 (cl-count 'complementary-light custom-enabled-themes))))
      (when (custom-theme-enabled-p 'complementary-light)
        (disable-theme 'complementary-light)))))

(ert-deftest complementary-themes-package-metadata-exists ()
  (let ((descriptor (expand-file-name "complementary-themes-pkg.el"
                                      complementary-light-test-root)))
    (should (file-readable-p descriptor))
    (with-temp-buffer
      (insert-file-contents descriptor)
      (should (equal (car (read (current-buffer))) 'define-package)))))

(ert-deftest complementary-themes-entry-point-loads-both-configurations ()
  (should (require 'complementary-themes nil t))
  (should (featurep 'complementary-light))
  (should (featurep 'complementary-dark))
  (should (custom-variable-p 'complementary-light-primary-color))
  (should (custom-variable-p 'complementary-dark-primary-color))
  (should (member (file-name-as-directory complementary-themes--root-directory)
                  custom-theme-load-path)))

(ert-deftest complementary-themes-declare-color-scheme-metadata ()
  (unwind-protect
      (progn
        (load-theme 'complementary-light t)
        (load-theme 'complementary-dark t)
        (dolist (check '((complementary-light light)
                         (complementary-dark dark)))
          (let ((properties (get (car check) 'theme-properties)))
            (should (eq (plist-get properties :family) 'complementary))
            (should (eq (plist-get properties :kind) 'color-scheme))
            (should (eq (plist-get properties :background-mode)
                        (cadr check))))))
    (dolist (theme '(complementary-dark complementary-light))
      (when (custom-theme-enabled-p theme)
        (disable-theme theme)))))

(ert-deftest complementary-light-preview-builds-in-batch ()
  (load (expand-file-name "lisp/complementary-light-preview.el"
                          complementary-light-test-root) nil nil t)
  (let ((buffer (generate-new-buffer " *complementary-preview-test*")))
    (unwind-protect
        (with-current-buffer buffer
          (complementary-light-preview-mode)
          (setq complementary-light-preview-primary 'yellow
                complementary-light-preview-secondary 'purple)
          (complementary-light-preview-redraw)
          (should (search-forward "Emacs Lisp" nil t))
          (should (search-forward "Accent tokens" nil t)))
      (kill-buffer buffer))))

(provide 'complementary-light-load-test)
;;; complementary-light-load-test.el ends here
