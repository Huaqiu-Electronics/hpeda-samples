;; HQ-LISP sample: ActionEngine same-chain line tool + synthetic clicks (LISP-4).
;; Preconditions: a design is open (06_open_and_read.lsp).
;; Usage:
;;   lisp-load Samples/Scripts/Lisp/08_action_line.lsp
;;
;; CreateLineAction commits only after Enter/Close (or double-click), not on the
;; second click alone. Do NOT call action-cancel before finalize — that discards
;; the sketch (symptoms: prompts advance, board unchanged).

(display ";; action-current (before) = ")
(display (action-current))
(newline)

;; Same path as menu / toolbar: actionBuilder → submitAction.
(action-start "line")

(display ";; action-current (after start) = ")
(display (action-current))
(newline)

;; Paper-mm clicks: 1st = anchor, 2nd = complete one line segment in sketch.
(action-input 'click 10.0 10.0)
(action-input 'click 25.0 20.0)

(display ";; action-current (after clicks, before enter) = ")
(display (action-current))
(newline)

;; Finalize via Command path (same as console "enter" / Close option).
;; Equivalent: (action-input 'key 'enter)
(action-input 'command "enter")

(display ";; action-current (after enter) = ")
(display (action-current))
(newline)

(display ";; selection-count = ")
(display (selection-count))
(newline)

(display ";; done: one LineFigure segment should exist (10,10)-(25,20) mm")
(newline)
(cmdlet "zoomall")