;; 对齐 Js 13：move_component → 框选 → 参考点 → 跟手 → 放下 → 保存。
;;
;; 板：02_components_pads（R1@12,-12；C1@28,-12）。
;; 接口走产品原语封装，不直接拼 cmdlet。
;;
;; Usage:
;;   lisp-load Samples/Scripts/Lisp/13_action_move_component.lsp

(define *board*
  (or (resolve-file "Samples/Boards/hqpcbx/02_components_pads.hqpcbx")
      (error "board sample not found")))

(open-and-wait *board* 30000)
(zoom-all)
(start-action "move_component")

;; 左→右框选 R1+C1（Intersect）。
(mouse-box-select 8.0 -16.0 32.0 -8.0 10)

;; 参考点：R1 中心。
(mouse-click 12.0 -12.0)

;; 跟手平移约 +6,+6 mm 后放下。
(mouse-move-ex 12.0 -12.0 18.0 -6.0 12)
(mouse-click 18.0 -6.0)

(save-project)
(zoom-all)
