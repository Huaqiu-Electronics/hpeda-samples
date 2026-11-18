#!/usr/bin/env node
"use strict";
const { resolvePipe, boardPath, checkEnv, loadSdk } = require("./helper");

async function main() {
  const { pipe, gui, rest } = resolvePipe(process.argv);
  const path = boardPath(rest[0], "components");
  const { createClientFactory, api } = loadSdk();
  const cli = createClientFactory();
  await cli.connect(pipe, { gui });
  if (checkEnv(cli)) {
    cli.disconnect();
    process.exit(1);
  }
  await cli.wsOpen(path);
  console.log("pipe=" + cli.pipe + " path=" + path);
  const fps = api
    .parseListV1(await cli.doAction("board.footprints", ""))
    .items.map((r) => new api.Footprint(r));
  console.log("footprint_count=" + fps.length);
  fps.slice(0, 10).forEach((fp) => {
    console.log(
      "  " + fp.refdes + " pkg=" + JSON.stringify(fp.package) + " placed=" + fp.placed
    );
  });
  const pads = api.parseListV1(await cli.doAction("board.pads", "")).items.map((r) => new api.Pad(r));
  console.log("pad_count=" + pads.length);
  pads.slice(0, 8).forEach((p) => {
    console.log("  pin=" + JSON.stringify(p.pin_number) + " net_id=" + p.net_id);
  });
  const layers = api
    .parseListV1(await cli.doAction("board.layers", ""))
    .items.map((r) => new api.LayerInfo(r));
  console.log(
    "layer_count=" + layers.length + " copper=" + layers.filter((l) => l.is_conductor).length
  );
  cli.disconnect();
}

main().catch((e) => {
  console.error(e && e.stack ? e.stack : e);
  process.exit(1);
});
