#!/usr/bin/env bash
# Tip E2E：pcb-wit-run + RPC + HostToGuest（无文件桥 / 无 wac）。
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../../../.." && pwd)"
SAMPLE="$(cd "$(dirname "$0")/.." && pwd)"
APP="${PCB_APP_RESOURCES:-$ROOT/cmake-build-release/Runtime/App/HQ PCB.app/Contents/Resources}"
export PATH="$HOME/go/bin:$HOME/.cargo/bin:$APP/tinygo/arm64/bin:$APP/binaryen/arm64/bin:$APP/wasm-tools/arm64:$APP/go/arm64/bin:$APP/goscript:$PATH"
export TINYGOROOT="${TINYGOROOT:-$APP/tinygo/arm64}"
export WASMOPT="${WASMOPT:-$APP/binaryen/arm64/bin/wasm-opt}"

WIT_RUN="${PCB_WIT_RUN:-}"
if [[ -z "$WIT_RUN" ]]; then
  for c in \
    "$APP/goscript/pcb-wit-run" \
    "$ROOT/Interop/PcbWitRun/target/release/pcb-wit-run" \
    "$ROOT/pcb-wit-run-cargo-target/release/pcb-wit-run"
  do
    if [[ -x "$c" ]]; then WIT_RUN="$c"; break; fi
  done
fi
if [[ -z "$WIT_RUN" ]]; then
  echo "pcb-wit-run not found (set PCB_WIT_RUN or build Interop/PcbWitRun)" >&2
  exit 1
fi

cd "$SAMPLE"
echo "== guest (witbridge) =="
tinygo build -tags witbridge -target=./wasip2-hqpcb.json -o guest.wasm .

HOST="$(mktemp -d /tmp/pcb-wit-host.XXXXXX)"
RPC="$HOST/host.rpc.sock"
HTG="$HOST/host.htg.sock"
mkdir -p "$HOST/req" "$HOST/resp" "$HOST/inbox"
python3 scripts/rpc_host.py "$RPC" &
RPC_PID=$!
python3 scripts/host_to_guest_accept.py "$HTG" &
HTG_PID=$!
cleanup() {
  kill "$RPC_PID" "$HTG_PID" 2>/dev/null || true
  wait "$RPC_PID" "$HTG_PID" 2>/dev/null || true
  rm -rf "$HOST"
}
trap cleanup EXIT
# 等监听就绪。
sleep 0.3

echo "== pcb-wit-run =="
"$WIT_RUN" --dir "$HOST" \
  --env "PCB_HOST_DIR=$HOST" \
  --env "PCB_HOST_RPC=$RPC" \
  --env "PCB_HOST_TO_GUEST=$HTG" \
  guest.wasm

# 无 guest 写 req / 无 inbox：计数须为 0。
REQ_COUNT="$(find "$HOST/req" -type f | wc -l | tr -d ' ')"
INBOX_COUNT="$(find "$HOST/inbox" -type f | wc -l | tr -d ' ')"
echo "req_files=$REQ_COUNT inbox_files=$INBOX_COUNT"
if [[ "$REQ_COUNT" != "0" || "$INBOX_COUNT" != "0" ]]; then
  echo "FAIL: expected req/inbox file count 0" >&2
  exit 1
fi
echo "OK: pcb-wit-run Log E2E (no file-bridge)"
