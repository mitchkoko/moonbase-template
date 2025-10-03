package com.example.moonbase

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetProvider

class TimeTrackerWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray, widgetData: SharedPreferences) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_layout).apply {
                val yesterdayTotal = widgetData.getString("yesterday_total", "Yesterday: 0h 0m")
                val timerState = widgetData.getString("timer_state", "Stopped")
                val elapsedTime = widgetData.getString("elapsed_time", "")

                setTextViewText(R.id.tv_yesterday_total, yesterdayTotal)
                if (timerState == "Running") {
                    setTextViewText(R.id.btn_start_stop, "Stop\n$elapsedTime")
                } else {
                    setTextViewText(R.id.btn_start_stop, "Start")
                }

                val pendingIntent = HomeWidgetBackgroundIntent.getBroadcast(
                    context,
                    Uri.parse("timetracker://start_stop_widget")
                )
                setOnClickPendingIntent(R.id.btn_start_stop, pendingIntent)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}