;; HQ-LISP sample: (choose-file) → (open-and-wait …) → (zoom-all).
;;
;; Usage:
;;   lisp-load Samples/Scripts/Lisp/11_choose_file.lsp
;;
;; (choose-file) 弹出与菜单 Open 同链的工程对话框，返回绝对路径；
;; 取消时抛 choose-file-error。不自动开板，需再 (open-and-wait)。

(display ";; choose-file: pick a .hqpcb / .hqpcbx …")
(newline)

(define *board* (choose-file))

(display ";; chosen ")
(display *board*)
(newline)

(open-and-wait *board* 30000)
(zoom-all)

(display ";; open ok")
(newline)
