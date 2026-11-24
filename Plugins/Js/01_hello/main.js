/**
 * Samples JS hello plugin — 注册命令，菜单触发后 showMessage。
 * 加载：loadplugin Samples/Plugins/Js/01_hello/plugin.yaml
 */
const CMD_HELLO = "samples_js_hello";

App({
  onLoad(args) {
    console.log("[samples.js.hello] onLoad args=" + JSON.stringify(args || []));
  },
  onAppInit() {
    const rt = this.runtime;
    rt.registerCommandCallback(
      CMD_HELLO,
      (_args) => {
        rt.showMessage("Samples JS", "Hello from Samples/Plugins/Js/01_hello", 0, 4000);
        return 0;
      },
      "Samples JS Hello",
      "Minimal JavaScript plugin sample"
    );
  },
});
