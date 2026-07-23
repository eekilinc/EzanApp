package com.example.ezan_app

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.ezan_app/vibration_alarm"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "scheduleVibration" -> {
                    val delayMs = call.argument<Int>("delayMs") ?: 0
                    val requestCode = call.argument<Int>("requestCode") ?: 0
                    scheduleVibrationAlarm(delayMs.toLong(), requestCode)
                    result.success(true)
                }
                "cancelVibration" -> {
                    val requestCode = call.argument<Int>("requestCode") ?: 0
                    cancelVibrationAlarm(requestCode)
                    result.success(true)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun scheduleVibrationAlarm(delayMs: Long, requestCode: Int) {
        val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager

        // Always cancel existing alarm with this requestCode first
        cancelVibrationAlarm(requestCode)

        val intent = Intent(this, VibrationReceiver::class.java).apply {
            action = VibrationReceiver.ACTION_VIBRATE
            // Add unique timestamp extra to make this PendingIntent distinct
            putExtra("trigger_time", System.currentTimeMillis() + delayMs)
        }

        // Use FLAG_CANCEL_CURRENT to ensure a completely fresh PendingIntent
        val pendingIntent = PendingIntent.getBroadcast(
            this,
            requestCode,
            intent,
            PendingIntent.FLAG_CANCEL_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val triggerTime = System.currentTimeMillis() + delayMs

        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                if (alarmManager.canScheduleExactAlarms()) {
                    alarmManager.setAlarmClock(
                        AlarmManager.AlarmClockInfo(triggerTime, null),
                        pendingIntent
                    )
                } else {
                    alarmManager.setExactAndAllowWhileIdle(
                        AlarmManager.RTC_WAKEUP,
                        triggerTime,
                        pendingIntent
                    )
                }
            } else {
                alarmManager.setAlarmClock(
                    AlarmManager.AlarmClockInfo(triggerTime, null),
                    pendingIntent
                )
            }
        } catch (e: Exception) {
            // Fallback: use inexact alarm
            try {
                alarmManager.setAndAllowWhileIdle(
                    AlarmManager.RTC_WAKEUP,
                    triggerTime,
                    pendingIntent
                )
            } catch (e2: Exception) {
                e2.printStackTrace()
            }
        }
    }

    private fun cancelVibrationAlarm(requestCode: Int) {
        val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(this, VibrationReceiver::class.java).apply {
            action = VibrationReceiver.ACTION_VIBRATE
        }
        // Use FLAG_NO_CREATE to check if a PendingIntent exists, then cancel it
        val existingIntent = PendingIntent.getBroadcast(
            this,
            requestCode,
            intent,
            PendingIntent.FLAG_NO_CREATE or PendingIntent.FLAG_IMMUTABLE
        )
        if (existingIntent != null) {
            alarmManager.cancel(existingIntent)
            existingIntent.cancel()
        }
    }
}
