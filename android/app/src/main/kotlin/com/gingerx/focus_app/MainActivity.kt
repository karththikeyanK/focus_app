package com.gingerx.focus_app

import android.content.Intent
import android.provider.Settings
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.gingerx.focus_app/service"

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
                    val isEnabled = enabledServices?.contains("com.gingerx.focus_app/com.gingerx.focus_app.AppLockAccessibilityService") == true
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


                "openAccessibilitySettings" -> {
                    val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    startActivity(intent)
                    result.success(true)
                }
                "openAppSettings" -> {
                    val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
                    intent.data = android.net.Uri.parse("package:$packageName")
                    startActivity(intent)
                    result.success(true)
                }


                else -> result.notImplemented()
            }
        }
    }
}
