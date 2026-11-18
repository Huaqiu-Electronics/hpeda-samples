;; HQ-LISP sample: open a V5 .hqpcb then read workspace / layer / selection.
;; Usage:
;;   lisp-load Samples/Scripts/Lisp/06_open_and_read.lsp
;; Optional override before load:
;;   lisp-eval (define *board* "/abs/path/to/board.hqpcb")
;;
;; Default board is resolved via (pcb-resolve …) against load roots so that
;; launching from HQ PCB.app (cwd under Contents/MacOS) does NOT open a
;; 0-byte stub created by a previous relative project.open.

(define *board*
  (if (defined? '*board*)
      *board*
      (or (pcb-resolve "Samples/Boards/hqpcb/01_tracks_vias.hqpcb")
          (pcb-resolve "Boards/hqpcb/01_tracks_vias.hqpcb")
          (error "board sample not found; set *board* to an absolute .hqpcb path"))))

(display ";; open ")
(display *board*)
(newline)

;; 内置开板：相对路径会先 pcb-resolve，再 project.open path=urlencode。
(project-open *board*)

(display ";; workspace-id = ")
(display (workspace-id))
(newline)

(display ";; layer-current = ")
(display (layer-current))
(newline)

(display ";; selection-count = ")
(display (selection-count))
(newline)

(display ";; selection-ids = ")
(display (selection-ids))
(newline)

;; Optional: list workspaces through cmdlet (text echo).
(cmdlet "workspace.list")
