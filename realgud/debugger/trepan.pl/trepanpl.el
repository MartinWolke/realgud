;;; Copyright (C) 2011, 2014 Rocky Bernstein <rocky@gnu.org>
;;  `trepanpl' Main interface to trepanpl via Emacs
(require 'list-utils)
(require 'load-relative)
(require-relative-list '("../../common/helper") "realgud-")
(require-relative-list '("../../common/track")  "realgud-")
(require-relative-list '("../../common/run")    "realgud:")
(require-relative-list '("core" "track-mode")   "realgud:trepanpl-")

;; This is needed, or at least the docstring part of it is needed to
;; get the customization menu to work in Emacs 23.
(defgroup trepanpl nil
  "The Perl \"trepanning\" debugger"
  :group 'processes
  :group 'perl
  :group 'realgud
  :version "23.1")

;; -------------------------------------------------------------------
;; User definable variables
;;

(defcustom realgud:trepanpl-command-name
  "trepan.pl"
  "File name for executing the Perl debugger and command options.
This should be an executable on your path, or an absolute file name."
  :type 'string
  :group 'trepanpl)

;; -------------------------------------------------------------------
;; The end.
;;

(declare-function realgud:trepanpl-track-mode     'realgud-trepanpl-track)
(declare-function realgud:trepanpl-query-cmdline  'realgud-trepanpl-core)
(declare-function realgud:trepanpl-parse-cmd-args 'realgud-trepanpl-core)
(declare-function realgud:run-process             'realgud-run)

; ### FIXME: DRY with other top-level routines
;;;###autoload
(defun realgud:trepanpl (&optional opt-command-line no-reset)
  "Invoke the trepan.pl Perl debugger and start the Emacs user interface.

String OPT-COMMAND-LINE specifies how to run trepan.pl. You will be prompted
for a command line is one isn't supplied.

OPT-COMMAND-LINE is treated like a shell string; arguments are
tokenized by `split-string-and-unquote'. The tokenized string is
parsed by `realgud:trepanpl-parse-cmd-args' and path elements found by that
are expanded using `expand-file-name'.

Normally, command buffers are reused when the same debugger is
reinvoked inside a command buffer with a similar command. If we
discover that the buffer has prior command-buffer information and
NO-RESET is nil, then that information which may point into other
buffers and source buffers which may contain marks and fringe or
marginal icons is reset. See `loc-changes-clear-buffer' to clear
fringe and marginal icons.
"
  (interactive)
  (let* ((cmd-str (or opt-command-line
		      (realgud:trepanpl-query-cmdline "trepan.pl")))
	 (cmd-args (split-string-and-unquote cmd-str))
	 (parsed-args (realgud:trepanpl-parse-cmd-args cmd-args))
	 (script-args (caddr parsed-args))
	 (script-name (car script-args))
	 (parsed-cmd-args
	  (list-utils-flatten (list (cadr parsed-args) (caddr parsed-args))))
	 )
    (realgud:run-process "trepan.pl" script-name parsed-cmd-args
			 'realgud:trepanpl-track-mode no-reset)
    )
  )

(defalias 'trepan.pl 'realgud:trepanpl)
(provide-me "realgud-")
;;; trepanpl.el ends here
