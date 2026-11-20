#!/usr/bin/env node
"use strict";
const { resolvePipe, boardPath, checkEnv, loadSdk } = require("./helper");

async function main() {
  const { gui, rest } = resolvePipe(process.argv);
  const path = boardPath(rest[0], "arc_tracks");
  const { createConnection, api } = loadSdk();
  const cli = await createConnection(gui);
  if (checkEnv(cli)) {
    cli.disconnect();
    process.exit(1);
  }
  await cli.wsOpen(path);
  console.log("pipe=" + cli.pipe + " path=" + path);
  const parsed = api.parseTracesV1(await cli.doAction("board.tracks", ""));
  const tracks = parsed.tracks || [];
  console.log("track_count=" + tracks.length);
  tracks.slice(0, 8).forEach((t) => {
    console.log(
      "  net=" +
        JSON.stringify(t.get_netname()) +
        " w=" +
        t.get_width().toFixed(4) +
        " len=" +
        t.length().toFixed(4)
    );
  });
  const byNet = {};
  tracks.forEach((t) => {
    const n = t.get_netname();
    byNet[n] = (byNet[n] || 0) + t.length();
  });
  const items = Object.keys(byNet)
    .map((k) => ({ k, v: byNet[k] }))
    .sort((a, b) => b.v - a.v);
  console.log(
    "nets_with_tracks=" + items.length + " total_mm=" + items.reduce((s, x) => s + x.v, 0).toFixed(4)
  );
  items.slice(0, 10).forEach((it) => console.log("  " + JSON.stringify(it.k) + " total_mm=" + it.v.toFixed(4)));
  cli.disconnect();
}

main().catch((e) => {
  console.error(e && e.stack ? e.stack : e);
  process.exit(1);
});
