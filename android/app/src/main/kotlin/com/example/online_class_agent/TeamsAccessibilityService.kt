package com.example.online_class_agent

import android.accessibilityservice.AccessibilityService
import android.content.Context
import android.accessibilityservice.AccessibilityServiceInfo
import android.content.SharedPreferences
import android.graphics.Rect
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo
import java.util.Locale

class TeamsAccessibilityService : AccessibilityService() {

    private val prefs: SharedPreferences by lazy {
        applicationContext.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
    }

    private val handler = Handler(Looper.getMainLooper())
    private var pendingTeamName: String? = null
    private var lastEventTime = 0L
    private val debounceMs = 2000L
    private var meetingBannerCheckStartTime = 0L
    private var isLookingForBanner = false
    private val meetingBannerCheckRunnable = Runnable { stepLookForMeetingStartedBanner() }
    private var teamListScrollAttempts = 0
    private val maxTeamListScrollAttempts = 25

    companion object {
        private const val TAG = "ProxyAIA11y"
        private const val PENDING_TEAM_KEY = "flutter.proxyai_pending_team"
        private const val DELAY_MS = 4000L
        private const val RETRY_INTERVAL_MS = 30_000L
        private const val MAX_WAIT_MS = 15 * 60 * 1000L
        private const val MEETING_STARTED_TEXT = "meeting started"
        private const val MIN_Y_CONTENT = 300
        private const val SCROLL_RETRY_DELAY_MS = 1000L
    }

    override fun onServiceConnected() {
        super.onServiceConnected()
        val info = AccessibilityServiceInfo().apply {
            eventTypes = AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED or
                    AccessibilityEvent.TYPE_VIEW_TEXT_CHANGED or
                    AccessibilityEvent.TYPE_WINDOW_CONTENT_CHANGED
            packageNames = arrayOf("com.microsoft.teams")
            feedbackType = AccessibilityServiceInfo.FEEDBACK_GENERIC
            flags = AccessibilityServiceInfo.FLAG_INCLUDE_NOT_IMPORTANT_VIEWS
            notificationTimeout = 500
        }
        serviceInfo = info
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event == null || event.packageName?.toString() != "com.microsoft.teams") return
        pendingTeamName = prefs.getString(PENDING_TEAM_KEY, null)?.takeIf { it.isNotBlank() }
        if (pendingTeamName == null) return
        val now = System.currentTimeMillis()
        if (now - lastEventTime < debounceMs) return
        lastEventTime = now
        handler.postDelayed({ performTeamsFlow() }, 800)
    }

    override fun onInterrupt() {}

    private fun performTeamsFlow() {
        val teamName = pendingTeamName ?: return
        val root = rootInActiveWindow ?: return
        try {
            if (isLookingForBanner) {
                if (tapJoinNextToMeetingStartedBanner(root)) {
                    handler.removeCallbacks(meetingBannerCheckRunnable)
                    isLookingForBanner = false
                    handler.postDelayed({ stepPreJoinScreen() }, DELAY_MS)
                }
                return
            }
            if (tapTeamByName(root, teamName)) {
                teamListScrollAttempts = 0
                handler.postDelayed({ stepGeneralChannel() }, DELAY_MS)
            } else if (tapJoinNextToMeetingStartedBanner(root)) {
                handler.postDelayed({ stepPreJoinScreen() }, DELAY_MS)
            } else if (teamListScrollAttempts < maxTeamListScrollAttempts && scrollTeamListDown(root)) {
                teamListScrollAttempts++
                handler.postDelayed({ performTeamsFlow() }, SCROLL_RETRY_DELAY_MS)
            } else {
                teamListScrollAttempts = 0
            }
        } catch (e: Exception) {
            Log.e(TAG, "Flow error", e)
        }
    }

    private fun stepGeneralChannel() {
        val root = rootInActiveWindow ?: return
        findAndTapGeneralChannel(root)
        meetingBannerCheckStartTime = System.currentTimeMillis()
        isLookingForBanner = true
        handler.postDelayed({ stepLookForMeetingStartedBanner() }, DELAY_MS)
    }

    private fun stepLookForMeetingStartedBanner() {
        if (pendingTeamName == null) return
        val root = rootInActiveWindow ?: return
        if (tapJoinNextToMeetingStartedBanner(root)) {
            handler.removeCallbacks(meetingBannerCheckRunnable)
            isLookingForBanner = false
            handler.postDelayed({ stepPreJoinScreen() }, DELAY_MS)
            return
        }
        val elapsed = System.currentTimeMillis() - meetingBannerCheckStartTime
        if (elapsed >= MAX_WAIT_MS) {
            Log.d(TAG, "Meeting started banner not found after 15 min, stopping")
            handler.removeCallbacks(meetingBannerCheckRunnable)
            isLookingForBanner = false
            clearPending()
            return
        }
        handler.postDelayed(meetingBannerCheckRunnable, RETRY_INTERVAL_MS)
    }

    private fun stepPreJoinScreen() {
        handler.postDelayed({
            val root = rootInActiveWindow ?: return@postDelayed
            turnOffMicIfOnPreJoin(root)
            handler.postDelayed({
                val r2 = rootInActiveWindow ?: return@postDelayed
                turnOffVideoIfOnPreJoin(r2)
                handler.postDelayed({
                    val r3 = rootInActiveWindow ?: return@postDelayed
                    tapJoinNow(r3)
                    handler.postDelayed({ stepMuteAfterJoin() }, DELAY_MS)
                }, 1000)
            }, 1000)
        }, DELAY_MS)
    }

    private fun stepMuteAfterJoin() {
        val root = rootInActiveWindow ?: return
        muteMicIfOnInMeeting(root)
        handler.postDelayed({ clearPending() }, 1000)
    }

    private fun tapTeamByName(root: AccessibilityNodeInfo, name: String): Boolean {
        val target = name.lowercase(Locale.getDefault()).trim()
        if (target.isEmpty()) return false
        val nodes = mutableListOf<AccessibilityNodeInfo>()
        findNodesContainingText(root, target, nodes)
        for (node in nodes) {
            val nodeText = node.text?.toString()?.lowercase(Locale.getDefault())?.trim() ?: collectTextFromNode(node).lowercase(Locale.getDefault()).trim()
            if (nodeText.contains(target) && tapClickable(node)) return true
        }
        return false
    }

    private fun scrollTeamListDown(root: AccessibilityNodeInfo): Boolean {
        val scrollables = mutableListOf<AccessibilityNodeInfo>()
        collectScrollableNodes(root, scrollables)
        for (node in scrollables) {
            if (node.performAction(AccessibilityNodeInfo.ACTION_SCROLL_FORWARD)) return true
        }
        return false
    }

    private fun collectScrollableNodes(node: AccessibilityNodeInfo, out: MutableList<AccessibilityNodeInfo>) {
        if (node.isScrollable) out.add(node)
        for (i in 0 until node.childCount) {
            node.getChild(i)?.let { collectScrollableNodes(it, out) }
        }
    }

    private fun findAndTapGeneralChannel(root: AccessibilityNodeInfo) {
        val nodes = mutableListOf<AccessibilityNodeInfo>()
        findNodesContainingText(root, "general", nodes)
        for (node in nodes) {
            val text = collectTextFromNode(node).lowercase(Locale.getDefault())
            if (text == "general" || (text.contains("general") && text.length < 20)) {
                if (tapClickable(node)) return
            }
        }
    }

    private fun tapJoinNextToMeetingStartedBanner(root: AccessibilityNodeInfo): Boolean {
        val teamName = pendingTeamName?.lowercase(Locale.getDefault()) ?: ""
        val bannerNodes = mutableListOf<AccessibilityNodeInfo>()
        findNodesContainingTextInContentArea(root, MEETING_STARTED_TEXT, bannerNodes)
        for (banner in bannerNodes) {
            if (nodeTextContainsExcluded(banner, teamName)) continue
            val joinNode = findJoinButtonNearNode(banner, teamName)
            if (joinNode != null && tapClickable(joinNode)) return true
        }
        return false
    }

    private fun findJoinButtonNearNode(nearNode: AccessibilityNodeInfo, teamName: String): AccessibilityNodeInfo? {
        val root = rootInActiveWindow ?: return null
        val nearRect = Rect()
        nearNode.getBoundsInScreen(nearRect)
        val joinCandidates = mutableListOf<AccessibilityNodeInfo>()
        findNodesWithExactJoin(root, joinCandidates)
        for (join in joinCandidates) {
            if (nodeTextContainsExcluded(join, teamName)) continue
            val joinRect = Rect()
            join.getBoundsInScreen(joinRect)
            if (joinRect.top < MIN_Y_CONTENT) continue
            val horizontalSlop = 200
            val verticalSlop = 150
            if (joinRect.left <= nearRect.right + horizontalSlop &&
                joinRect.right >= nearRect.left - horizontalSlop &&
                joinRect.top <= nearRect.bottom + verticalSlop &&
                joinRect.bottom >= nearRect.top - verticalSlop
            ) {
                return join
            }
        }
        var parent = nearNode.parent ?: return null
        for (i in 0 until parent.childCount) {
            val sibling = parent.getChild(i) ?: continue
            val join = findJoinInSubtree(sibling, teamName)
            if (join != null) return join
        }
        parent = parent.parent ?: return null
        for (i in 0 until parent.childCount) {
            val uncle = parent.getChild(i) ?: continue
            val join = findJoinInSubtree(uncle, teamName)
            if (join != null) return join
        }
        return null
    }

    private fun findNodesWithExactJoin(node: AccessibilityNodeInfo, out: MutableList<AccessibilityNodeInfo>) {
        val t = node.text?.toString()?.trim()?.lowercase(Locale.getDefault()) ?: ""
        val d = node.contentDescription?.toString()?.trim()?.lowercase(Locale.getDefault()) ?: ""
        if ((t == "join" || d == "join") && !t.contains("join now")) out.add(node)
        for (i in 0 until node.childCount) {
            node.getChild(i)?.let { findNodesWithExactJoin(it, out) }
        }
    }

    private fun findJoinInSubtree(node: AccessibilityNodeInfo, teamName: String): AccessibilityNodeInfo? {
        val t = node.text?.toString()?.trim()?.lowercase(Locale.getDefault()) ?: ""
        val d = node.contentDescription?.toString()?.trim()?.lowercase(Locale.getDefault()) ?: ""
        if ((t == "join" || d == "join") && !t.contains("join now") && !nodeTextContainsExcluded(node, teamName)) return node
        for (i in 0 until node.childCount) {
            node.getChild(i)?.let { findJoinInSubtree(it, teamName) }?.let { return it }
        }
        return null
    }

    private fun nodeTextContainsExcluded(node: AccessibilityNodeInfo?, teamName: String): Boolean {
        if (node == null) return true
        val text = collectTextFromNode(node).lowercase(Locale.getDefault())
        if (text.contains("general")) return true
        if (teamName.isNotBlank() && text.contains(teamName)) return true
        return false
    }

    private fun turnOffMicIfOnPreJoin(root: AccessibilityNodeInfo) {
        findAndTapByContentDesc(root, "mute", "turn off microphone", "microphone")
    }

    private fun turnOffVideoIfOnPreJoin(root: AccessibilityNodeInfo) {
        findAndTapByContentDesc(root, "turn off camera", "stop video", "camera")
    }

    private fun muteMicIfOnInMeeting(root: AccessibilityNodeInfo) {
        val nodes = mutableListOf<AccessibilityNodeInfo>()
        findNodesByContentDesc(root, "mute", nodes)
        findNodesByContentDesc(root, "microphone", nodes)
        findNodesByContentDesc(root, "mic", nodes)
        for (node in nodes) {
            val desc = node.contentDescription?.toString()?.trim()?.lowercase(Locale.getDefault()) ?: ""
            if (desc.contains("unmute") || desc.contains("turn on microphone")) continue
            if (desc == "mute" || desc.contains("turn off microphone")) {
                if (tapClickable(node)) return
            }
        }
    }

    private fun findAndTapByContentDesc(root: AccessibilityNodeInfo, vararg descs: String) {
        for (desc in descs) {
            val nodes = mutableListOf<AccessibilityNodeInfo>()
            findNodesByContentDesc(root, desc, nodes)
            for (node in nodes) {
                val rect = Rect()
                node.getBoundsInScreen(rect)
                if (rect.top < MIN_Y_CONTENT) continue
                if (tapClickable(node)) return
            }
        }
    }

    private fun tapJoinNow(root: AccessibilityNodeInfo) {
        val nodes = mutableListOf<AccessibilityNodeInfo>()
        findNodesContainingText(root, "join now", nodes)
        for (node in nodes) {
            val rect = Rect()
            node.getBoundsInScreen(rect)
            if (rect.top < MIN_Y_CONTENT) continue
            val text = node.text?.toString()?.lowercase(Locale.getDefault()) ?: ""
            if (text.contains("join now") && tapClickable(node)) return
        }
    }

    private fun tapClickable(node: AccessibilityNodeInfo?): Boolean {
        var n = node
        while (n != null) {
            if (n.isClickable) {
                n.performAction(AccessibilityNodeInfo.ACTION_CLICK)
                return true
            }
            n = n.parent
        }
        return false
    }

    private fun collectTextFromNode(node: AccessibilityNodeInfo): String {
        val sb = StringBuilder()
        node.text?.toString()?.let { sb.append(it).append(' ') }
        node.contentDescription?.toString()?.let { sb.append(it).append(' ') }
        for (i in 0 until node.childCount) {
            node.getChild(i)?.let { sb.append(collectTextFromNode(it)) }
        }
        return sb.toString()
    }

    private fun findNodesContainingText(node: AccessibilityNodeInfo, text: String, out: MutableList<AccessibilityNodeInfo>) {
        val t = node.text?.toString()?.lowercase(Locale.getDefault()) ?: ""
        if (t.contains(text)) out.add(node)
        for (i in 0 until node.childCount) {
            node.getChild(i)?.let { findNodesContainingText(it, text, out) }
        }
    }

    private fun findNodesContainingTextInContentArea(node: AccessibilityNodeInfo, text: String, out: MutableList<AccessibilityNodeInfo>) {
        val rect = Rect()
        node.getBoundsInScreen(rect)
        val t = node.text?.toString()?.lowercase(Locale.getDefault()) ?: ""
        if (t.contains(text) && rect.top >= MIN_Y_CONTENT) out.add(node)
        for (i in 0 until node.childCount) {
            node.getChild(i)?.let { findNodesContainingTextInContentArea(it, text, out) }
        }
    }

    private fun findNodesByContentDesc(node: AccessibilityNodeInfo, desc: String, out: MutableList<AccessibilityNodeInfo>) {
        val d = node.contentDescription?.toString()?.lowercase(Locale.getDefault()) ?: ""
        if (d.contains(desc)) out.add(node)
        for (i in 0 until node.childCount) {
            node.getChild(i)?.let { findNodesByContentDesc(it, desc, out) }
        }
    }

    private fun clearPending() {
        handler.removeCallbacks(meetingBannerCheckRunnable)
        prefs.edit().remove(PENDING_TEAM_KEY).apply()
        pendingTeamName = null
    }
}
