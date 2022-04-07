;;; emacs-logging.el --- Log all commands or slow commands in emacs -*- lexical-binding: t -*-

(defvar emacs-logging/log-directory "~/.emacs.d/logs/")
(defvar emacs-logging/log-every-command t)
(defvar emacs-logging/log-slow-commands t)
(defvar emacs-logging/log-slow-command-threshold 0.5)
(defvar emacs-logging/log-slow-command-last-command nil)

(defun emacs-logging/log-command (&optional cmd)
  (when emacs-logging/log-every-command
    (let ((now (format-time-string "%Y-%m-%d"))
          (inhibit-message t))
      (write-region (format "[%s] %s %s\n"
                            (format-time-string "%Y-%m-%dT%H:%M:%SZ")
                            (key-description (this-command-keys))
                            (or cmd this-command))
                    nil
                    (concat emacs-logging/log-directory now ".log")
                    'append
                    'silent))))

(add-hook 'pre-command-hook 'emacs-logging/log-command)

(defun emacs-logging/log-slow-commands-before (&optional cmd)
  (when emacs-logging/log-slow-commands
    (setq emacs-logging/log-slow-command-last-command
          (list (or cmd this-command) (float-time)))))

(defun emacs-logging/log-slow-commands-after (&optional cmd)
  (when (and emacs-logging/log-slow-commands
             emacs-logging/log-slow-command-last-command)
    (let ((inhibit-message t)
          (difference (- (float-time)
                         (cadr emacs-logging/log-slow-command-last-command))))
      (when (< emacs-logging/log-slow-command-threshold difference)
        (write-region (format "[%s] %s %s %fs\n"
                              (format-time-string "%Y-%m-%dT%H:%M:%SZ")
                              (key-description (this-command-keys))
                              (or cmd this-command)
                              difference)
                      nil
                      (concat emacs-logging/log-directory "slow.log")
                      'append
                      'silent)))))

(add-hook 'pre-command-hook 'emacs-logging/log-slow-commands-before)

(add-hook 'post-command-hook 'emacs-logging/log-slow-commands-after)

(provide 'emacs-logging)
