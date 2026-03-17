package com.example.online_class_agent

import android.app.KeyguardManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.app.Activity
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.os.PowerManager
import android.util.Log
import android.view.WindowManager

class WakeAndOpenActivity : Activity() {

    companion object {
        private const val TAG = "ProxyAI"
        const val EXTRA_TEAM_NAME = "team_name"
        private const val TEAMS_PACKAGE = "com.microsoft.teams"
        private const val WAKE_LOCK_DURATION_MS = 90_000L
        private const val DELAY_AFTER_KEYGUARD_DISMISS_MS = 600L
        private const val FALLBACK_LAUNCH_TEAMS_MS = 4000L
    }

    private var wasStopped = false
    private var teamsLaunched = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
        }
        window.addFlags(
            WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON or
            WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD or
            WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
            WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
        )
        val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
        @Suppress("DEPRECATION")
        val wakeLock = powerManager.newWakeLock(
            PowerManager.SCREEN_BRIGHT_WAKE_LOCK or PowerManager.ACQUIRE_CAUSES_WAKEUP or PowerManager.ON_AFTER_RELEASE,
            "ProxyAI::WakeLock"
        )
        wakeLock.acquire(WAKE_LOCK_DURATION_MS)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val keyguardManager = getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager
            keyguardManager.requestDismissKeyguard(this, object : KeyguardManager.KeyguardDismissCallback() {
                override fun onDismissSucceeded() {
                    scheduleLaunchTeams()
                }
                override fun onDismissCancelled() {
                    scheduleLaunchTeams()
                }
            })
        } else {
            scheduleLaunchTeams()
        }

        Handler(Looper.getMainLooper()).postDelayed({
            if (!teamsLaunched) scheduleLaunchTeams()
        }, FALLBACK_LAUNCH_TEAMS_MS)

        Handler(Looper.getMainLooper()).postDelayed({
            wakeLock.release()
        }, WAKE_LOCK_DURATION_MS)
    }

    private fun scheduleLaunchTeams() {
        Handler(Looper.getMainLooper()).postDelayed({
            launchTeams()
        }, DELAY_AFTER_KEYGUARD_DISMISS_MS)
    }

    override fun onStop() {
        super.onStop()
        wasStopped = true
    }

    override fun onResume() {
        super.onResume()
        if (wasStopped) {
            finish()
        }
    }

    private fun launchTeams() {
        if (teamsLaunched) return
        teamsLaunched = true
        var intent = applicationContext.packageManager.getLaunchIntentForPackage(TEAMS_PACKAGE)
        if (intent == null) {
            intent = Intent(Intent.ACTION_MAIN).apply {
                setPackage(TEAMS_PACKAGE)
                addCategory(Intent.CATEGORY_LAUNCHER)
            }
            val resolveInfo = applicationContext.packageManager.resolveActivity(intent, PackageManager.MATCH_ALL)
            if (resolveInfo != null) {
                intent.setClassName(resolveInfo.activityInfo.packageName, resolveInfo.activityInfo.name)
            } else {
                Log.e(TAG, "Teams app not found: $TEAMS_PACKAGE")
                finish()
                return
            }
        }
        intent.addFlags(
            Intent.FLAG_ACTIVITY_NEW_TASK or
            Intent.FLAG_ACTIVITY_CLEAR_TOP or
            Intent.FLAG_ACTIVITY_REORDER_TO_FRONT or
            Intent.FLAG_ACTIVITY_RESET_TASK_IF_NEEDED
        )
        try {
            applicationContext.startActivity(intent)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to launch Teams", e)
            finish()
        }
    }
}
