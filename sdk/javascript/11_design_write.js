#!/usr/bin/env node
"use strict";
/**
 * 设计租约写：批量 props + 错 token 拒写（默认板 01_tracks_vias）。
 * 用法：./run 11_design_write.js
 */
const { resolvePipe, boardPath, checkEnv, loadSdk } = require("./helper");

async function main() {
  const { gui, rest } = resolvePipe(process.argv);
  const boardFile = boardPath(rest[0] || null, "tracks");
  const { createConnection } = loadSdk();
  const cli = await createConnection(gui);
  if (checkEnv(cli)) {
    cli.disconnect();
    return 1;
  }
  console.log("pipe=" + cli.pipe);
  console.log("--- ws.open ---");
  console.log(String(await cli.wsOpen(boardFile)).trimEnd());

  console.log("--- writeProps (lease batch) ---");
  const got = await cli.writeProps(
    {
      "sample.note": "from-11-design-write",
      "sample.layer": "top",
      "sample.rev": "1",
    },
    "samples-sdk-write"
  );
  Object.keys(got).forEach(function (k) {
    console.log(k + "=" + got[k]);
  });

  console.log("--- reject wrong token while holding lease ---");
  const token = "holder-A";
  await cli.designLease(token);
  try {
    await cli.designSet("sample.guard", "held-by-A", token);
    let rejected = false;
    try {
      await cli.designSet("sample.guard", "stolen", "holder-B");
    } catch (ex) {
      rejected = true;
      console.log("ok reject: " + ex);
    }
    if (!rejected) {
      console.error("error: expected not_writer");
      return 1;
    }
    console.log("sample.guard=" + (await cli.designGet("sample.guard")));
  } finally {
    await cli.designRelease(token);
  }

  if (got["sample.note"] !== "from-11-design-write") return 1;
  cli.disconnect();
  return 0;
}

main()
  .then(function (code) {
    process.exit(code || 0);
  })
  .catch(function (e) {
    console.error(e && e.stack ? e.stack : e);
    process.exit(1);
  });
