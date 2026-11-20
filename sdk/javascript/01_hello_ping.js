#!/usr/bin/env node
"use strict";
const { resolvePipe, loadSdk } = require("./helper");

async function main() {
  const { gui } = resolvePipe(process.argv);
  const { createConnection  } = loadSdk();
  const cli = await createConnection(gui);
  const echo = await cli.ping("samples-sdk-01");
  const caps = cli.peerCaps || {};
  console.log("pipe=" + cli.pipe);
  console.log("role=" + cli.peerRole);
  console.log("ping=" + echo);
  console.log(
    "caps interactive=" +
      caps.interactive +
      " workspace=" +
      caps.workspace +
      " design=" +
      caps.design
  );
  cli.disconnect();
}

main().catch((e) => {
  console.error(e && e.stack ? e.stack : e);
  process.exit(1);
});
