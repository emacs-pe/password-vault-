;;; password-vault+.el --- A Password manager for Emacs. -*- lexical-binding: t -*-

;;; Author: Javier "PuercoPop" Olaechea <pirata@gmail.com>
;;; URL: http://github.com/PuercoPop/password-vault+.el
;;; Version: 0.0.1
;;; Keywords: password, productivity
;;; Package-Requires: ((cl-lib "0.2") (emacs "24") (helm "20150414.50"))

;;; Commentary:

;; It builds upon the pattern described in this post:
;; http://emacs-fu.blogspot.com/2011/02/keeping-your-secrets-secret.html

;; Usage: (password-vault+-register-secrets-file 'secrets.el)
;; M-x password-vault+

;;; License:
;; Copying is an act of love, please copy. ♡

;;; Code:

(eval-when-compile (require 'cl-lib))
(require 'helm)

;; So that locate-library works properly.
(add-to-list 'load-file-rep-suffixes ".gpg" t)


(define-derived-mode password-vault+-mode
  special-mode
  "password-vault+"
  "Major mode for copying the passwords you store in Emacs to the
  clipboard")

(defgroup password-vault+ nil
  "A password manager for Emacs"
  :group 'password-vault+)

(defcustom password-vault+-secret-file nil
  "The modules to load the passwords from."
  :group 'password-vault+)

(defvar password-vault+-reparse-secret-file t
  "Signals that the secret file should be read again.")

(defvar password-vault+-passwords nil
  "An alist mapping from name to password.")

(defvar password-vault+-helm-source nil)

(defvar password-vault+--hooks-queue nil
  "A list of modules that need to the `after-save-hook' installed.")

(defun password-vault+--install-hooks (modules)
  "Add an `after-save-hook' so that every module in MODULES is
marked as dirty upon saving."
  (dolist (module modules)
    (with-current-buffer (find-file-noselect (locate-library module))
      (add-hook 'after-save-hook
                (lambda ()
                  (setq password-vault+-reparse-secret-file t))))))

;;;###autoload
(defun password-vault+-register-secrets-file (module)
  "Load the setq forms to the MODULE to the password-vault+."
  (add-to-list 'password-vault+-secret-file module)
  (add-to-list 'password-vault+--hooks-queue module))

(defun password-vault+-update-passwords-helper (module)
  "Locate MODULE and add them to the alist."
  (with-current-buffer (find-file-noselect
                        (locate-library module) t)
    (setq buffer-read-only t)
    (setq password-vault+-passwords nil)
    (let ((sexp (read (buffer-substring-no-properties (point-min)
                                                      (point-max)))))
      (when (equal (car sexp) 'setq)
        (let ((pairs (cdr sexp)))
          (while pairs
            (add-to-list 'password-vault+-passwords (cons (prin1-to-string (car pairs))
                                                          (cadr pairs)))
            (setq pairs (cddr pairs))))))
    (setq buffer-read-only nil)))

(defun password-vault+-update-passwords ()
  "(re)Generate the password alist."
  (setq password-vault+-passwords nil)

  (dolist (module password-vault+-secret-file)
    (password-vault+-update-passwords-helper module))

  (setq password-vault+-helm-source
        `((name . "Password Vault+")
          (candidates . ,password-vault+-passwords)
          (action . (lambda (candidate)
                      (funcall 'interprogram-cut-function candidate)
                      "Password Copied to Clipboard")))))

;;;###autoload
(defun password-vault+ ()
  "Lists the passwords in the secret files."
  (interactive)

  (unless interprogram-cut-function
    (error "Interprogram clipboard must be enabled"))

  (when password-vault+--hooks-queue
    (password-vault+--install-hooks password-vault+--hooks-queue)
    (setf password-vault+--hooks-queue nil))

  (unless password-vault+-passwords
    (password-vault+-update-passwords))

  (helm :sources '(password-vault+-helm-source)))

(provide 'password-vault+)
;;; password-vault+.el ends here
