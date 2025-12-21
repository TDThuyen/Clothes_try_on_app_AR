package com.example.app_fe

import android.util.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

object SessionBridge {

    private const val CHANNEL = "unity/face_session"
    private var channel: MethodChannel? = null

    fun register(flutterEngine: FlutterEngine) {
        channel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        )
        Log.d("SessionBridge", "✅ MethodChannel registered")
    }

    // 🔥 Unity gọi hàm này
    @JvmStatic
    fun onFaceSessionCreated(sessionId: String) {
        Log.d("SessionBridge", "📩 sessionId from Unity = $sessionId")
        channel?.invokeMethod(
            "onFaceSessionCreated",
            sessionId
        )
    }
}
