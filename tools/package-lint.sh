#!/bin/sh -e

# The following is a derivative work of
# https://github.com/purcell/package-lint
# licensed under GNU General Public License v3.0.

EMACS="${EMACS:=emacs}"

INIT_PACKAGE_EL="(progn
  (require 'package)
  (push '(\"melpa\" . \"http://melpa.org/packages/\") package-archives)
  (package-initialize)
  (package-refresh-contents))"

rm -rf "$HOME"/.emacs.d/elpa/package-lint-*

# Get mainline package-lint, then replace package-lint.el with dickmao's.
# quelpa doesn't get data/stdlib-changes.gz for whatever reason.
"$EMACS" -Q -batch \
         --eval "$INIT_PACKAGE_EL" \
         --eval "(unless (package-installed-p (quote quelpa)) (package-install (quote quelpa)))" \
         --eval "(package-install (quote package-lint))" \
         --eval "(quelpa (quote (package-lint :fetcher github :repo \"dickmao/package-lint\" :branch \"datetime\")))" \
         --eval "(let ((dir (file-name-directory (locate-library \"package-lint\")))) (delete-file (expand-file-name \"package-lint.elc\" dir)) (copy-file (expand-file-name \"package-lint/package-lint.el\" quelpa-build-dir) (expand-file-name \"package-lint.el\" dir) t))"

BASENAME=$(basename "$1")
"$EMACS" -Q -batch \
         --eval "$INIT_PACKAGE_EL" \
         -l package-lint.el \
         --visit "$1" \
         --eval "(checkdoc-eval-current-buffer)" \
         --eval "(princ (with-current-buffer checkdoc-diagnostic-buffer (buffer-string)))" \
         2>&1 | egrep -a "^$BASENAME:" | egrep -v "Messages should start" && [ -n "${EMACS_LINT_IGNORE+x}" ]

# Lint ourselves
# Lint failures are ignored if EMACS_LINT_IGNORE is defined, so that lint
# failures on Emacs 24.2 and below don't cause the tests to fail, as these
# versions have buggy imenu that reports (defvar foo) as a definition of foo.
# Reduce purity via:
# --eval "(fset 'package-lint--check-defs-prefix (symbol-function 'ignore))" \
"$EMACS" -Q -batch \
         --eval "$INIT_PACKAGE_EL" \
         -l package-lint.el \
         -f package-lint-batch-and-exit \
         "$1" || [ -n "${EMACS_LINT_IGNORE+x}" ]
