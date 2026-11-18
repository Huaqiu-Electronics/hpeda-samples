"use strict";
/**
 * Samples/sdk/javascript 共用：端点、Boards/hqpcb 默认板、SDK 路径。
 */
const path = require("path");
const fs = require("fs");

const SVC_TOKENS = new Set(["headless", "service", "svc", "--headless", "--service"]);
const GUI_TOKENS = new Set(["gui", "--gui"]);
const SVC_PIPES = new Set(["hqpcb-svc"]);
const GUI_PIPES = new Set(["hqpcb-gui"]);

const BOARD_PRESETS = {
  tracks: "01_tracks_vias.hqpcb",
  arc_tracks: "05_arc_tracks_vias.hqpcb",
  components: "02_components_pads.hqpcb",
  zones: "03_zones_graphics.hqpcb",
  all_basics: "04_all_basics.hqpcb",
  keepout: "06_keepout_netclass.hqpcb",
  custom_pads: "07_custom_pads_curves.hqpcb",
  blind: "08_blind_bottom.hqpcb",
  slots: "09_slots_thermals.hqpcb",
  outline: "10_outline_arcs.hqpcb",
  diffpair: "11_diffpair_route.hqpcb",
};

function samplesRoot() {
  return path.resolve(__dirname, "../..");
}

function boardsHqpcbDir() {
  return path.join(samplesRoot(), "Boards", "hqpcb");
}

function sdkJsDir() {
  return path.resolve(samplesRoot(), "..", "sdk", "javascript");
}

function loadSdk() {
  const root = sdkJsDir();
  return {
    createPcbFlightIPC: require(path.join(root, "pcb_flight_IPC.js")).createPcbFlightIPC,
    api: require(path.join(root, "pcb_api_gen.js")),
  };
}

function resolvePipe(argv) {
  let gui = false;
  let pipe = null;
  const envEp = String(process.env.PCB_IPC_ENDPOINT || "").trim().toLowerCase();
  if (envEp === "gui" || envEp === "hqpcb-gui") gui = true;
  else if (["headless", "service", "svc", "hqpcb-svc"].includes(envEp)) gui = false;
  const out = [];
  for (const a of argv.slice(2)) {
    const low = String(a).toLowerCase();
    if (String(a).startsWith("grpc") || String(a).includes("://") || String(a).endsWith(".sock")) {
      console.error("error: 不要传 Flight URI / socket。");
      process.exit(2);
    }
    if (low.startsWith("--endpoint=")) {
      const val = low.split("=", 2)[1].trim();
      if (val === "gui" || val === "hqpcb-gui") {
        gui = true;
        pipe = null;
      } else if (["headless", "service", "svc", "hqpcb-svc"].includes(val)) {
        gui = false;
        pipe = null;
      } else {
        console.error("error: unknown --endpoint=" + val);
        process.exit(2);
      }
      continue;
    }
    if (GUI_TOKENS.has(low)) {
      gui = true;
      pipe = null;
      continue;
    }
    if (SVC_TOKENS.has(low)) {
      gui = false;
      pipe = null;
      continue;
    }
    if (GUI_PIPES.has(low)) {
      gui = true;
      pipe = a;
      continue;
    }
    if (SVC_PIPES.has(low)) {
      gui = false;
      pipe = a;
      continue;
    }
    out.push(a);
  }
  return { pipe, gui, rest: out };
}

function boardPath(arg, preset) {
  let p;
  if (arg) p = path.resolve(arg);
  else p = path.resolve(boardsHqpcbDir(), BOARD_PRESETS[preset] || preset);
  if (!fs.existsSync(p) || !fs.statSync(p).isFile()) {
    console.error("error: board not found: " + p);
    process.exit(1);
  }
  return p;
}

function requireWsDesign(cli) {
  const caps = cli.peerCaps || {};
  if (caps.workspace && caps.design) return null;
  console.error(
    "peer lacks workspace/design (pipe=" +
      cli.pipe +
      " role=" +
      cli.peerRole +
      ")\n请连 hqpcb-svc 或已声明 workspace+design 的 hqpcb-gui。"
  );
  return 1;
}

module.exports = {
  BOARD_PRESETS,
  resolvePipe,
  boardPath,
  requireWsDesign,
  loadSdk,
  sdkJsDir,
};
