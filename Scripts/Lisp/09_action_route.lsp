;; 对齐 Js 09_action_route：route → 锁角/线宽 → 起点 → dbclick via → cancel → save。
;;
;; Usage:
;;   lisp-load Samples/Scripts/Lisp/09_action_route.lsp

(define *board*
  (or (resolve-file "Samples/Boards/hqpcbx/01_tracks_vias.hqpcbx")
      (error "board sample not found")))

(open-and-wait *board* 30000)
(zoom-all)
(select-layer "Conductor1")
(start-action "route")

;; Angle Lock → 90°（index=1）；Line width → 0.4mm。
(set-action-param "angleLock" 1)
(set-action-param "lineWidth" 0.4)

(mouse-move-ex 0.0 0.0 18.0 -15.0 8)
(mouse-click 18.0 -15.0)
(mouse-move-ex 18.0 -15.0 28.0 -10.0 10)
(mouse-db-click 28.0 -10.0)

(cancel-action)
(save-project)
(zoom-all)
