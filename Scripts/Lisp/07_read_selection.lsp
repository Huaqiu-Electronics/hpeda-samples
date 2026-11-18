;; HQ-LISP sample: interactive read after the user selects objects on the board.
;; Preconditions:
;;   1) A design is open (see 06_open_and_read.lsp).
;;   2) In the canvas, select one or more objects (click / box).
;;   3) Then:
;;        lisp-load Samples/Scripts/Lisp/07_read_selection.lsp
;;
;; Reads selection via LISP-3 domain primitives and prints entity-get alist per id.

(display ";; workspace-id = ")
(display (workspace-id))
(newline)

(display ";; layer-current = ")
(display (layer-current))
(newline)

(define ids (selection-ids))
(display ";; selection-count = ")
(display (selection-count))
(newline)
(display ";; selection-ids = ")
(display ids)
(newline)

(define (show-entity id)
  (display ";; entity-get ")
  (display id)
  (display " => ")
  (display (entity-get id))
  (newline))

(define (for-each-id fn lst)
  (if (null? lst)
      #t
      (begin
        (fn (car lst))
        (for-each-id fn (cdr lst)))))

(if (null? ids)
    (begin
      (display ";; (no selection) select objects on the board, then reload this script")
      (newline))
    (for-each-id show-entity ids))
