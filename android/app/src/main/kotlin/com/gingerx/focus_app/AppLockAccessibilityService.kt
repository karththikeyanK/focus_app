package com.gingerx.focus_app
import android.accessibilityservice.AccessibilityServiceInfo
import android.content.Intent
import android.accessibilityservice.AccessibilityService
import android.view.accessibility.AccessibilityEvent



class AppLockAccessibilityService : AccessibilityService() {
    override fun onServiceConnected() {
        val info = AccessibilityServiceInfo().apply {
            eventTypes = AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED
            feedbackType = AccessibilityServiceInfo.FEEDBACK_ALL_MASK
            flags = AccessibilityServiceInfo.FLAG_REPORT_VIEW_IDS or
                    AccessibilityServiceInfo.FLAG_REQUEST_FILTER_KEY_EVENTS or
                    AccessibilityServiceInfo.FLAG_RETRIEVE_INTERACTIVE_WINDOWS
            notificationTimeout = 0 // Immediate response
        }
        this.serviceInfo = info
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        event?.let {
            if (it.eventType == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) {
                val packageName = it.packageName?.toString()
                val className = it.className?.toString()

                // Skip system components and our own app
                if (packageName == null ||
                    packageName.startsWith("android") ||
                    packageName == "com.gingerx.focus_app") {
                    return
                }

                val lockedApps = getSharedPreferences("AppLockPrefs", MODE_PRIVATE)
                    .getStringSet("locked_apps", emptySet()) ?: emptySet()

                if (packageName in lockedApps) {
                    // 1. Immediately go to home screen
                    performGlobalAction(GLOBAL_ACTION_HOME)

                    // 2. Start foreground service to show lock screen
                    val lockIntent = Intent(this, AppLockForegroundService::class.java).apply {
                        putExtra("locked_package", packageName)
                        flags = Intent.FLAG_ACTIVITY_NEW_TASK or
                                Intent.FLAG_ACTIVITY_CLEAR_TASK
                    }
                    startForegroundService(lockIntent)
                }
            }
        }
    }

    override fun onInterrupt() {}
}

