package com.example.app_fe

import android.content.Context
import android.view.View
import com.unity3d.player.UnityPlayer
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import io.flutter.plugin.common.StandardMessageCodec

class UnityViewFactory :
    PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    override fun create(context: Context, id: Int, args: Any?): PlatformView {
        return object : PlatformView {
            override fun getView(): View {
                return UnityPlayer.currentActivity
                    ?.let { UnityPlayer(it).view }
                    ?: View(context)
            }

            override fun dispose() {}
        }
    }
}
