package com.example.ezan_app

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class PrayerWidgetReceiver : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.prayer_widget_layout).apply {
                // Read data saved from Flutter via HomeWidget
                val prayerName = widgetData.getString("prayer_name", "Yükleniyor...") ?: "Yükleniyor..."
                val prayerTime = widgetData.getString("prayer_time", "--:--") ?: "--:--"
                val countdown = widgetData.getString("countdown", "--:--:--") ?: "--:--:--"
                val appTitle = widgetData.getString("app_title", "Ezan Hatırlatıcı") ?: "Ezan Hatırlatıcı"

                setTextViewText(R.id.widget_title, appTitle)
                setTextViewText(R.id.widget_prayer_name, prayerName)
                setTextViewText(R.id.widget_prayer_time, prayerTime)
                setTextViewText(R.id.widget_countdown, countdown)
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
