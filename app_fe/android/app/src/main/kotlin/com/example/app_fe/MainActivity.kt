private val OPEN_UNITY_CHANNEL = "unity/open"

override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)

    // Unity → Flutter (bạn đã có)
    SessionBridge.register(flutterEngine)

    // Flutter → Unity (BẮT BUỘC)
    MethodChannel(
        flutterEngine.dartExecutor.binaryMessenger,
        OPEN_UNITY_CHANNEL
    ).setMethodCallHandler { call, result ->
        if (call.method == "openUnity") {
            val intent = Intent(this, UnityActivity::class.java)
            startActivity(intent)
            result.success(null)
        } else {
            result.notImplemented()
        }
    }
}
