package com.example.ezan_app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager

class VibrationReceiver : BroadcastReceiver() {
    companion object {
        const val ACTION_VIBRATE = "com.example.ezan_app.ACTION_VIBRATE"
    }

    override fun onReceive(context: Context, intent: Intent?) {
        if (intent?.action == ACTION_VIBRATE) {
            try {
                val vibrator = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                    val vibratorManager = context.getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as VibratorManager
                    vibratorManager.defaultVibrator
                } else {
                    @Suppress("DEPRECATION")
                    context.getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
                }

                if (vibrator.hasVibrator()) {
                    // Vibration pattern: wait 0ms, vibrate 800ms, pause 400ms, vibrate 800ms, pause 400ms, vibrate 800ms
                    val pattern = longArrayOf(0, 800, 400, 800, 400, 800)

                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        vibrator.vibrate(VibrationEffect.createWaveform(pattern, -1))
                    } else {
                        @Suppress("DEPRECATION")
                        vibrator.vibrate(pattern, -1)
                    }
                }
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }
}
