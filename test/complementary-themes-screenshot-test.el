;;; complementary-themes-screenshot-test.el --- Screenshot generator tests  -*- lexical-binding: t; -*-

;;; Code:

(require 'ert)
(require 'complementary-themes-capture-screenshots)

(ert-deftest complementary-themes-screenshot-jobs-are-complete-and-unique ()
  (let ((filenames
         (mapcar #'complementary-themes-screenshot-filename
                 complementary-themes-screenshot-jobs)))
    (should (= (length filenames) 28))
    (should (= (length filenames)
               (length (delete-dups (copy-sequence filenames)))))
    (dolist (variant '(light dark))
      (dolist (color complementary-themes-screenshot-color-names)
        (should (member (format "01_%s-%s.png" variant color)
                        filenames)))
      (should (member (format "02_%s-yellow-red.png" variant) filenames))
      (should (member (format "02_%s-blue-green.png" variant) filenames)))))

(ert-deftest complementary-themes-screenshot-gallery-covers-manifest ()
  (let ((gallery-file
         (expand-file-name
          "Screenshots/README.org"
          complementary-themes-screenshot--root-directory))
        gallery-filenames)
    (with-temp-buffer
      (insert-file-contents gallery-file)
      (goto-char (point-min))
      (while (re-search-forward
              "\\[\\[file:\\([^]\n]+\\.png\\)\\]\\]" nil t)
        (push (match-string-no-properties 1) gallery-filenames)))
    (should
     (equal
      (sort gallery-filenames #'string<)
      (sort
       (mapcar #'complementary-themes-screenshot-filename
               complementary-themes-screenshot-jobs)
       #'string<)))))

(ert-deftest complementary-themes-screenshot-geometry-is-validated ()
  (should (eq (complementary-themes-screenshot--read-geometry nil)
              'maximized))
  (should (eq (complementary-themes-screenshot--read-geometry "maximized")
              'maximized))
  (should (equal
           (complementary-themes-screenshot--read-geometry "1600x900")
           '(1600 . 900)))
  (should-error
   (complementary-themes-screenshot--read-geometry "1600*900")
   :type 'user-error))

(provide 'complementary-themes-screenshot-test)
;;; complementary-themes-screenshot-test.el ends here
