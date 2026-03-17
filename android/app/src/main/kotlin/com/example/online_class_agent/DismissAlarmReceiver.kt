package com.example.online_class_agent

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class DismissAlarmReceiver : BroadcastReceiver() {

    companion object {
        private const val PENDING_TEAM_KEY = "flutter.proxyai_pending_team"
    }

    override fun onReceive(context: Context, intent: Intent?) {
        context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            .edit()
            .remove(PENDING_TEAM_KEY)
            .apply()
        context.stopService(Intent(context, AlarmRingingService::class.java))
    }
}
