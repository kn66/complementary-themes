;;; complementary-themes-preview.el --- Screenshot specimen  -*- lexical-binding: t; -*-

;; Neutral foundations, paired accents, and familiar Emacs semantics.
;; Ordinary code stays quiet while structure and state remain visible.

;;; Code:

(require 'cl-lib)
(require 'seq)
(require 'subr-x)

(defgroup complementary-preview nil
  "A compact specimen for theme screenshots."
  :group 'faces)

(defcustom complementary-preview-limit 4
  "Maximum number of projects shown in the preview."
  :type 'integer
  :group 'complementary-preview)

(cl-defstruct (complementary-preview-project
               (:constructor complementary-preview-project-create))
  title status priority tags)

(defconst complementary-preview-projects
  (list
   (complementary-preview-project-create
    :title "Palette review" :status 'ready :priority 1
    :tags '(design contrast))
   (complementary-preview-project-create
    :title "Face inventory" :status 'active :priority 2
    :tags '(emacs testing))
   (complementary-preview-project-create
    :title "Release notes" :status 'draft :priority 3
    :tags '(documentation)))
  "Projects displayed by the screenshot specimen.")

(defun complementary-preview-status-label (status)
  "Return a short display label for STATUS."
  (pcase status
    ('ready "READY")
    ('active "ACTIVE")
    ('draft "DRAFT")
    (_ "UNKNOWN")))

(defun complementary-preview-render (projects)
  "Format the first visible PROJECTS as a compact report."
  (let* ((visible (seq-take projects complementary-preview-limit))
         (lines
          (mapcar
           (lambda (project)
             (format "%-8s  %s  [%s]"
                     (complementary-preview-status-label
                      (complementary-preview-project-status project))
                     (complementary-preview-project-title project)
                     (string-join
                      (mapcar #'symbol-name
                              (complementary-preview-project-tags project))
                      ", ")))
           visible)))
    (string-join lines "\n")))

(message "\n%s" (complementary-preview-render complementary-preview-projects))

;;; complementary-themes-preview.el ends here
