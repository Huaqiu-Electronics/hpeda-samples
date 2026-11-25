#!/usr/bin/env bash
# Build guest (witbridge) + file-bridge adapter, wac plug, run with wasmtime + pump.
set -euo pipefail
# scripts/ → wasip2_wit_bridge → Go → Scripts → Samples → repo
ROOT="$(cd "$(dirname "$0")/../../../../.." && pwd)"
SAMPLE="$(cd "$(dirname "$0")/.." && pwd)"
APP="${PCB_APP_RESOURCES:-$ROOT/cmake-build-release/Runtime/App/HQ PCB.app/Contents/Resources}"
export PATH="$HOME/go/bin:$HOME/.cargo/bin:$APP/tinygo/arm64/bin:$APP/wasm-tools/arm64:$APP/go/arm64/bin:$APP/wasmtime/arm64:$PATH"

cd "$SAMPLE"
echo "== guest (witbridge) =="
tinygo build -tags witbridge -target=./wasip2-hqpcb.json -o guest.wasm .

echo "== adapter (file bridge export) =="
(
  cd adapter
  tinygo build -target=./wasip2-hqpcb-adapter.json -o ../adapter.wasm .
)

echo "== compose (wac plug) =="
wac plug --plug adapter.wasm guest.wasm -o composed.wasm

echo "== run =="
HOST="$(mktemp -d /tmp/pcb-wit-host.XXXXXX)"
mkdir -p "$HOST/req" "$HOST/resp"
python3 scripts/pump_host.py "$HOST" &
PUMP=$!
trap 'kill $PUMP 2>/dev/null || true; rm -rf "$HOST"' EXIT

# Map host dir into guest+adapter; PCB_HOST_DIR must match guest path.
wasmtime run --wasm component-model \
  --dir "$HOST::$HOST" \
  --env "PCB_HOST_DIR=$HOST" \
  composed.wasm

echo "OK: composed wasm exited"
