# Overview

A passwords manager for emacs. It builds upon the pattern described in the pattern described by [emacs-fu](http://emacs-fu.blogspot.com/2011/02/keeping-your-secrets-secret.html) and lets you copy your stored passwords to the clipboard easily. Uses Helm for the UI

# Installation

You can install password-vault+ directly from melpa: `M-x install-package password-vault+`.
Otherwise you can download `password-vault+.el` place it in your load path and either require it (`(require 'password-vault+)`) or write the autoloads by hand as shown below:

```elisp
(autoload 'password-vault "password-vault" "" t nil)
(autoload 'password-vault-register-secrets-file "password-vault")
```

# Usage

## In your init.el
```elisp
;; Module where you keep your passwords. ie:
(password-vault+-register-secrets-file "passwords")
```

```elisp
M-x password-vault+
```

# Example

## password-file

```elisp
(setq  freenode-nickserv-nick "DrSexyKittah"
       freenode-nickserv-password "CanIHazSecrets"
       ...
       wikipedia-password "Youllnevernowwhy")
```

![Screenshot](http://i.imgur.com/JhzoVsg.png)

# Improvements from password-vault
  - Automatically refreshes the passwords when the password file is modified
  - Uses Helm as UI, which allows to search through the password names  

# License
Copying is an act of Love, please copy.

# Author
PuercoPop <pirata@gmail.com>
