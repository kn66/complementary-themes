;;; complementary-light-test-helper.el --- Shared test setup  -*- lexical-binding: t; -*-

(require 'ert)
(require 'cl-lib)

(defconst complementary-light-test-root
  (file-name-directory
   (directory-file-name
    (file-name-directory (or load-file-name buffer-file-name)))))

(add-to-list 'load-path complementary-light-test-root)
(add-to-list 'load-path (expand-file-name "lisp" complementary-light-test-root))
(add-to-list 'load-path (expand-file-name "tools" complementary-light-test-root))
(add-to-list 'custom-theme-load-path complementary-light-test-root)

(require 'complementary-light)

(defun complementary-light-test-theme-colors ()
  "Return every registered color literal."
  (delete-dups
   (append (mapcar #'cdr complementary-light-neutral-palette)
           (cl-loop for (_ . palette) in complementary-light-palettes
                    append (cl-loop for (_ value) on palette by #'cddr
                                    collect value)))))

(provide 'complementary-light-test-helper)
;;; complementary-light-test-helper.el ends here
