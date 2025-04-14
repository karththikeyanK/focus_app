package com.example.focus_app

import android.content.Intent
import android.provider.Settings
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.focus_app/service"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "enableAppLock" -> {
                    val lockedApps = call.arguments as List<String>
                    val sharedPreferences = getSharedPreferences("AppLockPrefs", MODE_PRIVATE)
                    sharedPreferences.edit().putStringSet("locked_apps", lockedApps.toSet()).apply()

                    val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
                    startActivity(intent)
                    result.success(true)
                }

                "isAccessibilityEnabled" -> {
                    val enabledServices = Settings.Secure.getString(contentResolver, Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES)
                    val isEnabled = enabledServices?.contains("com.example.focus_app/com.example.focus_app.AppLockAccessibilityService") == true
                    result.success(isEnabled)
                }

                // 👇 This is the new method to handle Flutter app list updates
                "updateLockedApps" -> {
                    try {
                        val lockedApps = call.arguments as List<String>
                        val sharedPreferences = getSharedPreferences("AppLockPrefs", MODE_PRIVATE)
                        sharedPreferences.edit().putStringSet("locked_apps", lockedApps.toSet()).apply()
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("UPDATE_ERROR", "Failed to update locked apps", e.message)
                    }
                }


                else -> result.notImplemented()
            }
        }
    }
}
