;; HQ-LISP sample: define / lambda / let.
;; Usage: lisp-load Samples/Scripts/Lisp/02_define.lsp
(begin
  (define (square x) (* x x))
  (define add
    (lambda (a b) (+ a b)))
  (let ((n 6))
    (add (square n) 6)))
