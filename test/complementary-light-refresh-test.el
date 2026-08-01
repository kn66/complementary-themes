;;; complementary-light-refresh-test.el --- Refresh isolation tests  -*- lexical-binding: t; -*-

(require 'complementary-light-test-helper)

(deftheme complementary-light-test-neighbor "Test-only neighboring theme.")
(custom-theme-set-faces
 'complementary-light-test-neighbor
 '(shadow ((((class color)) (:foreground "gray50")))))

(ert-deftest complementary-light-refresh-is-idempotent-and-isolated ()
  (let ((user-before (copy-tree (get 'user 'theme-settings))))
    (unwind-protect
        (progn
          (enable-theme 'complementary-light-test-neighbor)
          (load-theme 'complementary-light t)
          (let ((order (copy-sequence custom-enabled-themes))
                (settings-count (length (get 'complementary-light
                                             'theme-settings))))
            (complementary-light-refresh)
            (complementary-light-refresh)
            (should (equal order custom-enabled-themes))
            (should (= settings-count
                       (length (get 'complementary-light 'theme-settings))))
            (should (= 1 (cl-count 'complementary-light custom-enabled-themes)))
            (should (custom-theme-enabled-p
                     'complementary-light-test-neighbor))
            (should (equal user-before (get 'user 'theme-settings)))))
      (when (custom-theme-enabled-p 'complementary-light)
        (disable-theme 'complementary-light))
      (when (custom-theme-enabled-p 'complementary-light-test-neighbor)
        (disable-theme 'complementary-light-test-neighbor)))))

(ert-deftest complementary-light-setting-while-disabled-does-not-enable ()
  (when (custom-theme-enabled-p 'complementary-light)
    (disable-theme 'complementary-light))
  (let ((old complementary-light-primary-color))
    (unwind-protect
        (progn
          (complementary-light-set-primary-color 'blue)
          (should-not (custom-theme-enabled-p 'complementary-light)))
      (setq complementary-light-primary-color old))))

(ert-deftest complementary-light-refresh-removes-obsolete-face-settings ()
  (unwind-protect
      (progn
        (load-theme 'complementary-light t)
        (custom-theme-set-faces
         'complementary-light
         '(mode-line-buffer-id ((t (:foreground "white")))))
        (should
         (cl-find-if
          (lambda (setting)
            (and (eq (car setting) 'theme-face)
                 (eq (nth 1 setting) 'mode-line-buffer-id)))
          (get 'complementary-light 'theme-settings)))
        (complementary-light-refresh)
        (should-not (assq 'complementary-light
                          (get 'mode-line-buffer-id 'theme-face)))
        (should-not
         (cl-find-if
          (lambda (setting)
            (and (eq (car setting) 'theme-face)
                 (eq (nth 1 setting) 'mode-line-buffer-id)))
          (get 'complementary-light 'theme-settings))))
    (when (custom-theme-enabled-p 'complementary-light)
      (disable-theme 'complementary-light))))

(provide 'complementary-light-refresh-test)
;;; complementary-light-refresh-test.el ends here
