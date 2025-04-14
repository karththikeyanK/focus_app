package com.example.focus_app
import android.accessibilityservice.AccessibilityServiceInfo
import android.content.Intent
import android.accessibilityservice.AccessibilityService
import android.view.accessibility.AccessibilityEvent

class AppLockAccessibilityService : AccessibilityService() {
    private var lockedApps = listOf<String>()

    override fun onServiceConnected() {
        val info = AccessibilityServiceInfo().apply {
            eventTypes = AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED
            feedbackType = AccessibilityServiceInfo.FEEDBACK_GENERIC
            flags = AccessibilityServiceInfo.FLAG_REPORT_VIEW_IDS
            notificationTimeout = 100
        }
        this.serviceInfo = info
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event?.eventType == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) {
            val packageName = event.packageName?.toString()

            // Get locked apps from SharedPreferences
            val sharedPrefs = getSharedPreferences("AppLockPrefs", MODE_PRIVATE)
            val lockedApps = sharedPrefs.getStringSet("locked_apps", emptySet()) ?: emptySet()

            if (packageName in lockedApps) {
                performGlobalAction(GLOBAL_ACTION_BACK)

                val intent = Intent(this, AppLockOverlayService::class.java)
                intent.putExtra("locked_package", packageName)
                startService(intent)
            }
        }
    }


    override fun onInterrupt() {}
}