;; HQ-LISP sample: open 01_tracks_vias → Route → mouse move/pause → click via
;; → rubber-band route → click waypoint → dbclick 打 via → action-cancel 退出 → zoomall.
;;
;; action-start / action-input 原语默认逐步延时（*action-step-ms* / *action-move-ms*）。
;; Override before load:
;;   (define *action-step-ms* 120)
;;   (define *action-move-ms* 40)
;;   (define *step-ms* 80)
;;   (define *after-start-ms* 300)
;;   (define *board* "/abs/path/to/01_tracks_vias.hqpcb")
;;
;; Usage:
;;   lisp-load Samples/Scripts/Lisp/09_action_route.lsp
;;
;; Paper mm (HQPCB): KiCad (at x y) imports with Y flipped.
;;   VCC via @ (18, -15); empty waypoint @ (28, -10).

(define *board*
  (if (defined? '*board*)
      *board*
      (or (pcb-resolve "Samples/Boards/hqpcb/01_tracks_vias.hqpcb")
          (pcb-resolve "Boards/hqpcb/01_tracks_vias.hqpcb")
          (error "board sample not found; set *board* to an absolute .hqpcb path"))))

;; 原语逐步延时（action-start / click / key / move-line 末）。
(define *action-step-ms*
  (if (defined? '*action-step-ms*) *action-step-ms* 80))

;; 原语 move / move-line 采样延时。
(define *action-move-ms*
  (if (defined? '*action-move-ms*) *action-move-ms* 25))

;; 样例额外 pause（叠在原语延时之上）。
(define *step-ms*
  (if (defined? '*step-ms*) *step-ms* 60))

;; 点 via 起线后短等避障引擎发布。
(define *after-start-ms*
  (if (defined? '*after-start-ms*) *after-start-ms* 200))

(define (pause)
  (sleep-ms *step-ms*))

(display ";; open ")
(display *board*)
(newline)

(project-open *board*)
(pause)
;; Wait scene follow so pick/hover hit vias (not empty GPU view).
(cmdlet "rasternext.wait_open_follow 30000")
(pause)
(cmdlet "zoomall")
(pause)

(display ";; action-current (before) = ")
(display (action-current))
(newline)

;; 先切到 Conductor1（传层名）：Route 面板 From/To 在底层会倒置，末点 dbclick 打孔会被拒绝。
(cmdlet "layer_schema.select Conductor1")
(pause)

;; Same toolbar chain as menu Route (lazy-loads builtin.route).
(action-start "route")
(pause)

(display ";; action-current (after start) = ")
(display (action-current))
(newline)

;; Approach the VCC via with visible mouse motion.
(action-input 'move-line 6.0 -6.0 18.0 -15.0 8)

;; Hover on via, then click to start Route.
(action-input 'move 18.0 -15.0)
(sleep-ms 80)
(action-input 'click 18.0 -15.0)
(pause)
;; Extra wait: AutoAvoid needs published xETAvoid after start.
(sleep-ms *after-start-ms*)

;; Rubber-band toward empty waypoint, then click to confirm a segment.
(action-input 'move-line 18.0 -15.0 28.0 -10.0 10)
(action-input 'click 28.0 -10.0)
(pause)

;; 末点 dbclick = 双击打 via（贴近已确认端点），提交走线并切到对层。
(action-input 'dbclick 28.0 -10.0)
(pause)

;; 打孔后仍停在 RouteAction（对层续布）；脚本结束前退出工具。
(action-cancel)
(pause)

(display ";; action-current (after via+cancel) = ")
(display (action-current))
(newline)

(cmdlet "zoomall")
(pause)

(display ";; done: routed via (18,-15)→(28,-10) + dblclick via + cancel + zoomall")
(newline)
