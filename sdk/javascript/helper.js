"use strict";
/**
 * Samples/sdk/javascript 共用：板路径等；端点解析用 SDK resolveEndpoint。
 */
const path = require("path");
const fs = require("fs");

const BOARD_PRESETS = {
  tracks: "01_tracks_vias.hqpcbx",
  arc_tracks: "05_arc_tracks_vias.hqpcbx",
  components: "02_components_pads.hqpcbx",
  zones: "03_zones_graphics.hqpcbx",
  all_basics: "04_all_basics.hqpcbx",
  keepout: "06_keepout_netclass.hqpcbx",
  custom_pads: "07_custom_pads_curves.hqpcbx",
  blind: "08_blind_bottom.hqpcbx",
  slots: "09_slots_thermals.hqpcbx",
  outline: "10_outline_arcs.hqpcbx",
  diffpair: "11_diffpair_route.hqpcbx",
};

function samplesRoot() {
  return path.resolve(__dirname, "../..");
}

function boardsHqpcbxDir() {
  return path.join(samplesRoot(), "Boards", "hqpcbx");
}

/** @deprecated 使用 boardsHqpcbxDir */
function boardsHqpcbDir() {
  return boardsHqpcbxDir();
}

function sdkJsDir() {
  return path.resolve(samplesRoot(), "..", "sdk", "javascript");
}

function loadSdk() {
  const root = sdkJsDir();
  const client = require(path.join(root, "hqeda_client.js"));
  return {
    createClientFactory: client.createClientFactory,
    createConnection: client.createConnection,
    NewConnection: client.NewConnection,
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
  else p = path.resolve(boardsHqpcbxDir(), BOARD_PRESETS[preset] || preset);
  if (!fs.existsSync(p) || !fs.statSync(p).isFile()) {
    console.error("error: board not found: " + p);
    console.error("hint: convert via Samples/Boards/convert_to_hqpcb.sh --hqpcbx-only");
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
  boardsHqpcbxDir,
  boardsHqpcbDir,
};
