"""Samples Python hello plugin — 注册命令，菜单触发后 show_message。

加载：loadplugin Samples/Plugins/Python/01_hello/plugin.yaml
"""

CMD_HELLO = "samples_py_hello"
_g_runtime = None
_app_registered = False


def initialize(runtime, args):
    global _g_runtime
    _g_runtime = runtime
    runtime.log_info("[samples.python.hello] initialize args=%s" % list(args))
    if "pcb_plugin_register_lifecycle" in globals():
        pcb_plugin_register_lifecycle(
            runtime,
            {
                "on_app_init": lambda _topic, _payload: _register_app(),
            },
        )
        return
    _register_app()


def _register_app():
    global _app_registered
    if _g_runtime is None or _app_registered:
        return
    _app_registered = True
    rt = _g_runtime

    def _on_hello(_args):
        rt.show_message(
            "Samples Python",
            "Hello from Samples/Plugins/Python/01_hello",
            0,
            4000,
        )
        return 0

    rt.register_command_callback(
        CMD_HELLO,
        _on_hello,
        "Samples Python Hello",
        "Minimal Python plugin sample",
    )


def shutdown():
    pass
