package com.example.change_app_icon

import androidx.annotation.NonNull
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    companion object {
        private const val CHANNEL = "com.example.change_app_icon/change_icon"
        private const val TAG = "MainActivity"
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                val iconManager = IconManager(applicationContext)

                when (call.method) {
                    "changeIcon" -> {
                        val iconName = call.arguments as? String
                        if (iconName.isNullOrBlank()) {
                            result.error("INVALID_ARGUMENT", "Icon name is required", null)
                            return@setMethodCallHandler
                        }

                        try {
                            iconManager.changeIcon(iconName)
                            result.success(true)
                        } catch (e: IllegalArgumentException) {
                            result.error("INVALID_ICON", e.message, null)
                        } catch (e: Exception) {
                            Log.e(TAG, "Error changing icon", e)
                            result.error("ICON_CHANGE_FAILED", e.message, null)
                        }
                    }

                    "getCurrentIcon" -> result.success(iconManager.getCurrentIcon())
                    else -> result.notImplemented()
                }
            }
    }
}
