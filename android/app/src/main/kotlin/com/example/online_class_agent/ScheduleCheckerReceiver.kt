package com.example.online_class_agent

import android.app.AlarmManager
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import org.json.JSONArray
import java.util.Calendar

class ScheduleCheckerReceiver : BroadcastReceiver() {

    companion object {
        private const val CHANNEL_ID = "proxyai_launch"
        private const val NOTIFICATION_ID_LAUNCH = 9001
    }

    override fun onReceive(context: Context, intent: Intent?) {
        val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val json = prefs.getString("flutter.proxyai_schedule", null) ?: return
        try {
            val array = JSONArray(json)
            val now = Calendar.getInstance()
            val today = now.get(Calendar.DAY_OF_WEEK)
            val dayMap = mapOf(
                Calendar.SUNDAY to 7,
                Calendar.MONDAY to 1,
                Calendar.TUESDAY to 2,
                Calendar.WEDNESDAY to 3,
                Calendar.THURSDAY to 4,
                Calendar.FRIDAY to 5,
                Calendar.SATURDAY to 6
            )
            val todayNum = dayMap[today] ?: 1
            val currentMinutes = now.get(Calendar.HOUR_OF_DAY) * 60 + now.get(Calendar.MINUTE)

            for (i in 0 until array.length()) {
                val obj = array.getJSONObject(i)
                if (!obj.optBoolean("enabled", true)) continue
                val daysArr = obj.optJSONArray("daysOfWeek") ?: continue
                var hasDay = false
                for (j in 0 until daysArr.length()) {
                    if (daysArr.getInt(j) == todayNum) {
                        hasDay = true
                        break
                    }
                }
                if (!hasDay) continue

                val hour = obj.optInt("hour", 0)
                val minute = obj.optInt("minute", 0)
                val classMinutes = hour * 60 + minute
                val fiveMinBefore = classMinutes - 5
                if (currentMinutes < fiveMinBefore || currentMinutes >= fiveMinBefore + 1) continue

                val id = obj.optString("id", "")
                val dateKey = "proxyai_trigger_$id"
                val todayStr = "${now.get(Calendar.YEAR)}-${now.get(Calendar.MONTH)}-${now.get(Calendar.DAY_OF_MONTH)}"
                if (prefs.getString(dateKey, null) == todayStr) continue
                prefs.edit().putString(dateKey, todayStr).apply()

                val teamName = obj.optString("teamName", "")
                prefs.edit().putString("flutter.proxyai_pending_team", teamName).apply()

                launchWakeActivity(context, teamName)

                var alarmTime = Calendar.getInstance().apply {
                    set(Calendar.HOUR_OF_DAY, hour)
                    set(Calendar.MINUTE, minute)
                    set(Calendar.SECOND, 0)
                    set(Calendar.MILLISECOND, 0)
                }.timeInMillis
                if (alarmTime <= System.currentTimeMillis()) {
                    alarmTime += 24 * 60 * 60 * 1000
                }
                val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
                val alarmIntent = Intent(context, AlarmReceiver::class.java)
                val pending = PendingIntent.getBroadcast(
                    context, 0, alarmIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                    if (alarmManager.canScheduleExactAlarms()) {
                        alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, alarmTime, pending)
                    } else {
                        alarmManager.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, alarmTime, pending)
                    }
                } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, alarmTime, pending)
                } else {
                    alarmManager.setExact(AlarmManager.RTC_WAKEUP, alarmTime, pending)
                }
                break
            }
            val nextIntent = Intent(context, ScheduleCheckerReceiver::class.java)
            val nextPending = PendingIntent.getBroadcast(
                context, 0, nextIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
            val nextTime = System.currentTimeMillis() + 60 * 1000
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                alarmManager.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, nextTime, nextPending)
            } else {
                alarmManager.set(AlarmManager.RTC_WAKEUP, nextTime, nextPending)
            }
        } catch (e: Exception) {
            Log.e("ScheduleChecker", "Error checking schedule", e)
        }
    }

    private fun launchWakeActivity(context: Context, teamName: String) {
        val wakeIntent = Intent(context, WakeAndOpenActivity::class.java).apply {
            addFlags(
                Intent.FLAG_ACTIVITY_NEW_TASK or
                Intent.FLAG_ACTIVITY_NO_HISTORY or
                Intent.FLAG_ACTIVITY_EXCLUDE_FROM_RECENTS or
                0x00080000 or
                0x00200000
            )
            putExtra(WakeAndOpenActivity.EXTRA_TEAM_NAME, teamName)
        }
        val fullScreenPending = PendingIntent.getActivity(
            context,
            NOTIFICATION_ID_LAUNCH,
            wakeIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "ProxyAI",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                setDescription("Opens Teams for class")
                setBypassDnd(true)
            }
            notificationManager.createNotificationChannel(channel)
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val notification = Notification.Builder(context, CHANNEL_ID)
                .setContentTitle("Joining class")
                .setContentText("Opening Teams…")
                .setSmallIcon(android.R.drawable.ic_dialog_info)
                .setCategory(Notification.CATEGORY_ALARM)
                .setFullScreenIntent(fullScreenPending, true)
                .setAutoCancel(true)
                .build()
            notificationManager.notify(NOTIFICATION_ID_LAUNCH, notification)
        }
        try {
            context.startActivity(wakeIntent)
        } catch (e: Exception) {
            Log.e("ScheduleChecker", "startActivity fallback", e)
        }
    }
}
