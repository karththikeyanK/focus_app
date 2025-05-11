package com.gingerx.focus_app

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Intent
import android.graphics.PixelFormat
import android.os.Build
import android.os.IBinder
import android.provider.Settings
import android.view.LayoutInflater
import android.view.View
import android.view.WindowManager

class AppLockForegroundService : Service() {

    private lateinit var windowManager: WindowManager
    private var overlayView: View? = null

    override fun onCreate() {
        super.onCreate()
        startForeground(1, createNotification())
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && Settings.canDrawOverlays(this)) {
            val lockedPackage = intent?.getStringExtra("locked_package")
            showLockScreen(lockedPackage)
        }
        return START_STICKY
    }

    private fun showLockScreen(packageName: String?) {
        windowManager = getSystemService(WINDOW_SERVICE) as WindowManager

        if (overlayView == null) {
            overlayView = LayoutInflater.from(this).inflate(R.layout.lock_screen, null)

            val params = WindowManager.LayoutParams(
                WindowManager.LayoutParams.MATCH_PARENT,
                WindowManager.LayoutParams.MATCH_PARENT,
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
                    WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
                else
                    WindowManager.LayoutParams.TYPE_PHONE,
                WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                        WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN or
                        WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL,
                PixelFormat.TRANSLUCENT
            )

            windowManager.addView(overlayView, params)

            // You can customize lock_screen.xml with buttons or PIN input, etc.
            // For example: overlayView?.findViewById<Button>(R.id.unlockButton)?.setOnClickListener { ... }
        }
    }

    private fun createNotification(): Notification {
        val channelId = "app_lock_channel"
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                channelId,
                "App Lock",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "App Lock is running"
            }
            getSystemService(NotificationManager::class.java)
                .createNotificationChannel(channel)
        }

        val notificationIntent = Intent(this, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(
            this, 0, notificationIntent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )

        return Notification.Builder(this, channelId)
            .setContentTitle("Focus App Lock Active")
            .setContentText("App lock service is running.")
            .setSmallIcon(R.drawable.ico)
            .setContentIntent(pendingIntent)
            .build()
    }

    override fun onDestroy() {
        super.onDestroy()
        overlayView?.let {
            windowManager.removeView(it)
            overlayView = null
        }
    }

    override fun onBind(intent: Intent?): IBinder? = null
}
