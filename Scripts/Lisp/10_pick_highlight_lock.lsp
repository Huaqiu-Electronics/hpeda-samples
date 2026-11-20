;; HQ-LISP sample: open 01_tracks_vias → pick → highlight/dehighlight → lock/unlock → hide.
;;
;; 对齐菜单：
;;   View/Highlight、View/Dehighlight（cmdlet highlight / dehighlight）
;;   Edit/Lock、Edit/Unlock（cmdlet lock / unlock）
;; 流程：rasternext.pick 选中后 start-action，工具对当前选择集立即 apply，
;;       再 cancel 退出并切回 Conductor1。
;;
;; Override before load:
;;   (define *step-ms* 80)
;;   (define *board* "/abs/path/to/01_tracks_vias.hqpcbx")
;;   (define *pick-x* 12.0)
;;   (define *pick-y* -20.0)
;;
;; Usage:
;;   lisp-load Samples/Scripts/Lisp/10_pick_highlight_lock.lsp
;;
;; Paper mm：样板板 (12,-20) 处有走线，便于稳定命中。

(define *board*
  (if (defined? '*board*)
      *board*
      (or (resolve-file "Samples/Boards/hqpcbx/01_tracks_vias.hqpcbx")
          (error "board sample not found; set *board* to an absolute .hqpcbx path"))))

(define *step-ms*
  (if (defined? '*step-ms*) *step-ms* 60))

(define *pick-x*
  (if (defined? '*pick-x*) *pick-x* 12.0))

(define *pick-y*
  (if (defined? '*pick-y*) *pick-y* -20.0))

;; 选中文档坐标处对象。
(define (pick-at-xy)
  (display ";; pick at (")
  (display *pick-x*)
  (display ",")
  (display *pick-y*)
  (display ")")
  (newline)
  (define out
    (cmdlet (string-append "rasternext.pick "
                           (number->string *pick-x*) " "
                           (number->string *pick-y*))))
  (display ";; pick = ")
  (display out)
  (newline)
  out)

;; cancel 后切回 Conductor1，避免工具退出后层态漂移导致后续 pick 落空。
(define (cancel-to-conductor1)
  (cancel-action)
  (select-layer "Conductor1")
  (sleep-ms *step-ms*))

(display ";; open ")
(display *board*)
(newline)

(open-and-wait *board* 30000)
(sleep-ms *step-ms*)
(zoom-all)
(sleep-ms *step-ms*)

;; 先切到 Conductor1，保证 (12,-20) 走线可命中。
(select-layer "Conductor1")
(sleep-ms *step-ms*)

;; 选中文档坐标处对象（与菜单先选中再点 Highlight/Lock 一致）。
(pick-at-xy)

;; View/Highlight：对当前选择集上色，工具保持激活，Esc/cancel 退出。
(display ";; highlight (menu View/Highlight)")
(newline)
(start-action "highlight")
(sleep-ms *step-ms*)
(cancel-to-conductor1)

;; apply 后选择集已清；再 pick 一次做 Dehighlight。
(pick-at-xy)
(display ";; dehighlight (menu View/Dehighlight)")
(newline)
(start-action "dehighlight")
(sleep-ms *step-ms*)
(cancel-to-conductor1)

;; Edit/Lock → Edit/Unlock。
(pick-at-xy)
(display ";; lock (menu Edit/Lock)")
(newline)
(start-action "lock")
(sleep-ms *step-ms*)
(cancel-to-conductor1)

(pick-at-xy)
(display ";; unlock (menu Edit/Unlock)")
(newline)
(start-action "unlock")
(sleep-ms *step-ms*)
(cancel-to-conductor1)

;; 再 pick 后 hide_items（内部 setStaticObjectsVisibleByIds）。
(pick-at-xy)
(define *hide-out* (cmdlet "rasternext.hide_items selection"))
(display ";; hide_items = ")
(display *hide-out*)
(newline)
(sleep-ms *step-ms*)

(display ";; done: pick + highlight/dehighlight + lock/unlock + hide")
(newline)
