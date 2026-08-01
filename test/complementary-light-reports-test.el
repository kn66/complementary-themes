;;; complementary-light-reports-test.el --- Audit report tests  -*- lexical-binding: t; -*-

(require 'complementary-light-test-helper)
(require 'complementary-light-generate-reports)

(ert-deftest complementary-light-color-vision-report-is-diagnostic-and-complete ()
  (let ((records (complementary-light-report--color-vision-records)))
    ;; 2 themes, 66 distinct pairs, 5 roles, 3x10 severities + grayscale.
    (should (= (length records) (* 2 66 5 31)))
    (dolist (record records)
      (should (member (cdr (assq 'simulation record))
                      '("protanomaly" "deuteranomaly" "tritanomaly"
                        "grayscale")))
      (if (equal (cdr (assq 'simulation record)) "grayscale")
          (should (eq (cdr (assq 'severity record)) :json-null))
        (should (<= 0.1 (cdr (assq 'severity record)) 1.0)))
      (should (>= (cdr (assq 'delta_e_2000_original record)) 0.0))
      (should (>= (cdr (assq 'delta_e_2000_simulated record)) 0.0))
      ;; A pass/fail field would incorrectly imply a universal Delta-E target.
      (should-not (assq 'passed record)))
    (should (= (length
                (complementary-light-report--color-vision-worst-case-records
                 records))
               (* 2 66 5 4)))))

(ert-deftest complementary-light-color-vision-ranking-matches-preset ()
  (let* ((records (complementary-light-report--color-vision-records))
         (rankings
          (complementary-light-report--color-vision-pair-rankings records))
         (best (car rankings)))
    (should (= (length rankings) 66))
    (should (= (cdr (assq 'rank best)) 1))
    (should (equal (cons (intern (cdr (assq 'primary best)))
                         (intern (cdr (assq 'secondary best))))
                   complementary-light-color-vision-preset))
    (should (eq (cdr (assq 'preset best)) t))))

(ert-deftest complementary-light-effective-face-audit-covers-inventory ()
  (let ((records
         (complementary-light-report--effective-face-contrast-records)))
    (should (= (length records)
               (* 2 (length (plist-get complementary-light-generated-inventory
                                       :faces)))))
    (dolist (face '(message-header-name erc-error-face
                    ediff-fine-diff-A eww-valid-certificate))
      (dolist (theme '("complementary-light" "complementary-dark"))
        (let ((record
               (cl-find-if
                (lambda (candidate)
                  (and (equal (cdr (assq 'face candidate))
                              (symbol-name face))
                       (equal (cdr (assq 'theme candidate)) theme)))
                records)))
          (should record)
          (should (eq (cdr (assq 'auditable record)) t))
          (should (equal (cdr (assq 'contrast_role record)) "normal-text"))
          (should (>= (cdr (assq 'ratio record))
                      complementary-light-text-contrast-target))
          (should (eq (cdr (assq 'review_candidate record)) :json-false))
          (should-not (eq (cdr (assq 'candidate_below_text_minimum record))
                          t)))))))

(ert-deftest complementary-light-effective-face-audit-is-role-aware ()
  (let ((records
         (complementary-light-report--effective-face-contrast-records)))
    (dolist (check '((org-hide "intentional-hidden")
                     (whitespace-big-indent "decorative")
                     (ansi-color-red "external-controlled")
                     (cursor "contextual")))
      (let ((matching
             (cl-remove-if-not
              (lambda (record)
                (equal (cdr (assq 'face record))
                       (symbol-name (car check))))
              records)))
        (should (= (length matching) 2))
        (dolist (record matching)
          (should (equal (cdr (assq 'contrast_role record)) (cadr check)))
          (should (eq (cdr (assq 'applicable_threshold record)) :json-null))
          (should (eq (cdr (assq 'review_candidate record)) :json-false)))))))

(ert-deftest complementary-light-themed-effective-contrast-passes-all-pairs ()
  (let ((records
         (complementary-light-report--themed-face-worst-case-records)))
    (should (= (length records)
               (* 2 (cl-count-if
                     (lambda (rule)
                       (eq (plist-get (cdr rule) :status) 'themed))
                     complementary-light-face-rules))))
    (dolist (record records)
      (unless (equal (cdr (assq 'role record)) "contextual-cursor")
        (should (eq (cdr (assq 'passed record)) t))))))

(ert-deftest complementary-light-cursor-gate-passes-all-common-surfaces ()
  (let ((records (complementary-light-report--cursor-contrast-records)))
    (should (= (length records)
               (* 2 132
                  (length complementary-light-cursor-background-tokens))))
    (dolist (record records)
      (should (equal (cdr (assq 'policy record)) "gated"))
      (should (eq (cdr (assq 'passed record)) t)))
    (should (= (length
                (complementary-light-report--cursor-worst-case-records
                 records))
               (* 2
                  (length complementary-light-cursor-background-tokens))))))

(provide 'complementary-light-reports-test)
;;; complementary-light-reports-test.el ends here
