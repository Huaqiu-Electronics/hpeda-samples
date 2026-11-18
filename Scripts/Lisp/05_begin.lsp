;; HQ-LISP sample: multi-form begin; last value is the result.
;; Usage: lisp-load Samples/Scripts/Lisp/05_begin.lsp
(begin
  (define xs (list 1 2 3 4))
  (define (sum lst)
    (if (null? lst)
        0
        (+ (car lst) (sum (cdr lst)))))
  (sum xs))
