#!/usr/bin/env node
"use strict";
/**
 * 工作区写：打开两块样板、切换、关闭。
 * 用法：./run 12_workspace_write.js
 */
const path = require("path");
const { resolvePipe, boardPath, checkEnv, loadSdk, sdkJsDir } = require("./helper");

async function main() {
  const { pipe, gui } = resolvePipe(process.argv);
  const a = boardPath(null, "tracks");
  const b = boardPath(null, "components");
  const { createClientFactory } = loadSdk();
  const { workspaceId } = require(path.join(sdkJsDir(), "hqeda_write.js"));
  const cli = createClientFactory();
  await cli.connect(pipe, { gui });
  if (checkEnv(cli)) {
    cli.disconnect();
    return 1;
  }
  console.log("pipe=" + cli.pipe);
  console.log("--- open A (tracks) ---");
  const snapA = await cli.wsOpen(a);
  const idA = workspaceId(snapA);
  console.log(String(snapA).trimEnd());
  console.log("--- open B (components) ---");
  const snapB = await cli.wsOpen(b);
  const idB = workspaceId(snapB);
  console.log(String(snapB).trimEnd());
  console.log("--- ws.list ---");
  const list = await cli.wsList();
  console.log(String(list).trimEnd());

  if (idA && idB && idA !== idB) {
    console.log("--- ws.switch → A id=" + idA + " ---");
    console.log(String(await cli.wsSwitch(idA)).trimEnd());
    console.log("--- ws.close B id=" + idB + " ---");
    console.log(String(await cli.wsClose(idB)).trimEnd());
  } else {
    const cur = workspaceId(list) || idB || idA;
    console.log("--- ws.close id=" + cur + " ---");
    if (cur) console.log(String(await cli.wsClose(cur)).trimEnd());
  }
  console.log("--- ws.list (after) ---");
  console.log(String(await cli.wsList()).trimEnd());
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
