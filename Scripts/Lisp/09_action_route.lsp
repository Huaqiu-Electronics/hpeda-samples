;; HQ-LISP sample: open 01_tracks_vias → Route → mouse move/pause → click via
;; → rubber-band route → click waypoint → dbclick 打 via → action-cancel 退出 → zoomall.
;;
;; action-start / action-input 原语默认逐步延时（*action-step-ms* / *action-move-ms*）。
;; Override before load:
;;   (define *action-step-ms* 120)
;;   (define *action-move-ms* 40)
;;   (define *step-ms* 80)
;;   (define *after-start-ms* 300)
;;   (define *board* "/abs/path/to/01_tracks_vias.hqpcbx")
;;
;; Usage:
;;   lisp-load Samples/Scripts/Lisp/09_action_route.lsp
;;
;; Paper mm (HQPCB): KiCad (at x y) imports with Y flipped.
;;   VCC via @ (18, -15); empty waypoint @ (28, -10).

(define *board*
  (if (defined? '*board*)
      *board*
      (or (resolve-file "Samples/Boards/hqpcbx/01_tracks_vias.hqpcbx")
          (error "board sample not found; set *board* to an absolute .hqpcbx path"))))

;; 原语逐步延时（action-start / click / key / move-line 末）。
(define *action-step-ms*
  (if (defined? '*action-step-ms*) *action-step-ms* 80))

;; 原语 move / move-line 采样延时。
(define *action-move-ms*
  (if (defined? '*action-move-ms*) *action-move-ms* 25))

;; 样例逐步停顿（叠在原语延时之上）。
(define *step-ms*
  (if (defined? '*step-ms*) *step-ms* 60))

;; 点 via 起线后短等避障引擎发布。
(define *after-start-ms*
  (if (defined? '*after-start-ms*) *after-start-ms* 200))

(display ";; open ")
(display *board*)
(newline)

;; open-and-wait：开板并等场景跟随，避免 pick/hover 打到空 GPU 视图。
(open-and-wait *board* 30000)
(sleep-ms *step-ms*)
(zoom-all)
(sleep-ms *step-ms*)

(display ";; action-current (before) = ")
(display (current-action))
(newline)

;; 先切到 Conductor1（传层名）：Route 面板 From/To 在底层会倒置，末点 dbclick 打孔会被拒绝。
(select-layer "Conductor1")
(sleep-ms *step-ms*)

;; Same toolbar chain as menu Route (lazy-loads builtin.route).
(start-action "route")
(sleep-ms *step-ms*)

(display ";; action-current (after start) = ")
(display (current-action))
(newline)

;; Approach the VCC via with visible mouse motion（末点已在 via 上，无需再 mouse-move）。
(mouse-move-ex 6.0 -6.0 18.0 -15.0 8)
(sleep-ms 80)
(mouse-click 18.0 -15.0)
(sleep-ms *step-ms*)
;; Extra wait: AutoAvoid needs published xETAvoid after start.
(sleep-ms *after-start-ms*)

;; Rubber-band toward empty waypoint, then click to confirm a segment.
(mouse-move-ex 18.0 -15.0 28.0 -10.0 10)
(mouse-click 28.0 -10.0)
(sleep-ms *step-ms*)

;; 末点 dbclick = 双击打 via（贴近已确认端点），提交走线并切到对层。
(mouse-db-click 28.0 -10.0)
(sleep-ms *step-ms*)

;; 打孔后仍停在 RouteAction（对层续布）；脚本结束前退出工具。
(cancel-action)
(sleep-ms *step-ms*)

(display ";; action-current (after via+cancel) = ")
(display (current-action))
(newline)

(zoom-all)
(sleep-ms *step-ms*)

(display ";; done: routed via (18,-15)→(28,-10) + dblclick via + cancel + zoomall")
(newline)
