;;; complementary-light-reports-test.el --- Audit report tests  -*- lexical-binding: t; -*-

(require 'complementary-light-test-helper)
(require 'complementary-light-generate-reports)

(ert-deftest complementary-light-color-vision-report-is-diagnostic-and-complete ()
  (let ((records (complementary-light-report--color-vision-records)))
    ;; 2 themes, 6 symmetric pairs, 5 roles, and 3 simulations.
    (should (= (length records) (* 2 6 5 3)))
    (dolist (record records)
      (should (member (cdr (assq 'simulation record))
                      '("protanopia" "deuteranopia" "tritanopia")))
      (should (>= (cdr (assq 'delta_e_2000_original record)) 0.0))
      (should (>= (cdr (assq 'delta_e_2000_simulated record)) 0.0))
      ;; A pass/fail field would incorrectly imply a universal Delta-E target.
      (should-not (assq 'passed record)))))

(provide 'complementary-light-reports-test)
;;; complementary-light-reports-test.el ends here
