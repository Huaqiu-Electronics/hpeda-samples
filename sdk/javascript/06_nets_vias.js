#!/usr/bin/env node
"use strict";
const { resolvePipe, boardPath, checkEnv, loadSdk } = require("./helper");

async function main() {
  const { pipe, gui, rest } = resolvePipe(process.argv);
  const path = boardPath(rest[0], "tracks");
  const { createClientFactory, api } = loadSdk();
  const cli = createClientFactory();
  await cli.connect(pipe, { gui });
  if (checkEnv(cli)) {
    cli.disconnect();
    process.exit(1);
  }
  await cli.wsOpen(path);
  console.log("pipe=" + cli.pipe + " path=" + path);
  const nets = api.parseListV1(await cli.doAction("board.nets", "")).items.map((r) => new api.Net(r));
  console.log("net_count=" + nets.length);
  nets.slice(0, 10).forEach((n) => {
    console.log("  net code=" + n.code + " name=" + JSON.stringify(n.name));
  });
  const vias = api.parseListV1(await cli.doAction("board.vias", "")).items.map((r) => new api.Via(r));
  console.log("via_count=" + vias.length);
  vias.slice(0, 8).forEach((v) => {
    console.log(
      "  via id=" +
        v.id +
        " net=" +
        JSON.stringify(v.net) +
        " xy=(" +
        Number(v.x_mm).toFixed(4) +
        "," +
        Number(v.y_mm).toFixed(4) +
        ") layers=" +
        v.layer_from_id +
        "->" +
        v.layer_to_id
    );
  });
  cli.disconnect();
}

main().catch((e) => {
  console.error(e && e.stack ? e.stack : e);
  process.exit(1);
});
