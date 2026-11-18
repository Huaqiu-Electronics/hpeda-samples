"use strict";
/**
 * Samples/sdk/javascript 共用：板路径等；端点解析用 SDK resolveEndpoint。
 */
const path = require("path");
const fs = require("fs");

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
    createClientFactory: require(path.join(root, "hqeda_client.js")).createClientFactory,
    createHqedaIPC: require(path.join(root, "hqeda_ipc.js")).createHqedaIPC,
    resolveEndpoint: require(path.join(root, "hqeda_endpoint.js")).resolveEndpoint,
    api: require(path.join(root, "hqeda_api_gen.js")),
  };
}

function resolveEndpoint(argv) {
  const { resolveEndpoint: sdkResolve } = loadSdk();
  try {
    return sdkResolve(argv);
  } catch (e) {
    console.error("error: " + (e && e.message ? e.message : e));
    process.exit(2);
  }
}

/** 兼容旧名。 */
function resolvePipe(argv) {
  return resolveEndpoint(argv);
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

function checkEnv(cli) {
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
  resolveEndpoint,
  resolvePipe,
  boardPath,
  checkEnv,
  loadSdk,
  sdkJsDir,
};
