# ProxyAI 🤖
### *Your AI-powered class attendance assistant*

> **Built for students who refuse to let 8am classes ruin their sleep.**

ProxyAI automatically joins your Microsoft Teams classes at the exact class time — while you are completely asleep. No alarm. No scrambling. No missing attendance. Just set it up once and sleep through every lecture like a professional.

---

## ⚡ What It Does

At class time, while you are dead asleep:

```
🔕 Phone is sleeping
        ↓
⏰ ProxyAI wakes up silently in background
        ↓
🔍 Checks your Teams General channel every 30 seconds for meeting link
        ↓
🔗 Meeting link found
        ↓
📱 Wakes your phone screen & dismisses lock screen
        ↓
🚀 Opens Microsoft Teams automatically
        ↓
🧭 Navigates → Your Team → General → Meeting Post → Join → Join Now
        ↓
🔇 Mutes mic & turns off camera
        ↓
✅ You are now in the meeting. Attendance marked.
        ↓
🔔 1 minute later — LOUD alarm fires to wake you up
        ↓
😴 You take over. Or go back to sleep. We don't judge.
```

---

## 🎯 Features

| Feature | Status |
|---|---|
| Fully automatic joining — zero user interaction | ✅ |
| Works while phone is asleep and screen is off | ✅ |
| Joins at exact class time | ✅ |
| Checks General channel every 30 seconds | ✅ |
| Mic off and camera off on join | ✅ |
| Loud alarm 1 minute after joining | ✅ |
| Alarm rings continuously until you tap "I'm Awake" | ✅ |
| Supports unlimited classes and subjects | ✅ |
| Per-class on/off toggle | ✅ |
| No Microsoft login required | ✅ |
| No servers — runs 100% on your device | ✅ |
| Clean minimal black and white UI | ✅ |

---

## 📲 Download

<br>

> **[⬇️ Download ProxyAI APK]()**
> *(link here)*

<br>

**Current Version:** v1.0.0
**Minimum Android:** 8.0 (Oreo)
**Size:** ~18MB

---

## 🛠️ Installation Guide

Follow these steps carefully — takes about 3 minutes total.

### 1️⃣ Disable Google Play Protect
Play Protect blocks apps installed outside the Play Store.

1. Open **Play Store**
2. Tap your **profile picture** → **Play Protect**
3. Tap the **gear icon** (Settings)
4. Turn OFF **"Scan apps with Play Protect"**
5. Turn OFF **"Improve harmful app detection"**

### 2️⃣ Install the APK
1. Download the ProxyAI APK from the link above
2. Open the file and tap **Install**
3. If blocked, go to **Settings → Apps → Special app access → Install unknown apps** and allow it

### 3️⃣ Allow Restricted Settings *(Android 13+ only)*
1. Go to **Settings → App Management → ProxyAI**
2. Tap the **three dots** in the top right
3. Tap **"Allow Restricted Settings"**

### 4️⃣ Enable Accessibility Service
This is how ProxyAI navigates Teams automatically.

1. Open **ProxyAI** app
2. Tap **"Enable Now"** when prompted
3. Find **ProxyAI** in Accessibility settings and toggle it **ON**

### 5️⃣ Remove Lock Screen Password
ProxyAI needs to unlock your screen automatically. Set lock screen to swipe only or none.

**Settings → Biometrics and Security → Screen Lock → Swipe / None**

### 6️⃣ Disable Battery Optimization
Prevents Android from killing ProxyAI while you sleep.

**Settings → Apps → ProxyAI → Battery → Unrestricted**

---

## 📚 Adding Your Classes

1. Open ProxyAI and tap **+**
2. Fill in:
   - **Class Name** — anything you want e.g. "Computer Networks"
   - **Team Name** — must match **exactly** as it appears in your Teams app
   - **Days** — which days this class occurs
   - **Time** — exact class start time
3. Toggle it **ON**
4. Done — never think about it again

> ⚠️ **Team Name must be exact.** Open your Teams app, find your subject, and copy the name character by character. Even one wrong letter and it won't find the meeting.

---

## 🔒 Privacy

ProxyAI is built with privacy first:

- **No Microsoft login** — your credentials stay with you
- **No servers** — everything runs locally on your phone
- **No data collection** — we collect nothing
- **No internet required** after setup — except for Teams itself
- **No message reading** — ProxyAI only navigates the Teams UI, it never reads your chats

---

## ❓ Troubleshooting

**Nothing happens at class time**
- Toggle is ON for the class ✓
- Team Name matches exactly ✓
- Accessibility Service still enabled ✓
- Battery optimization disabled ✓
- ProxyAI app was opened at least once after install ✓

**"Restricted Setting" error**
- Settings → App Management → ProxyAI → three dots → Allow Restricted Settings

**Teams opens but gets stuck**
- Make sure lock screen is set to Swipe or None (no pattern/PIN)
- Make sure Teams app is installed and you are logged in

**Alarm is too quiet**
- Turn up your phone's alarm volume in Settings → Sounds

---

## ⚙️ How It Works Under The Hood

ProxyAI uses Android's official **Accessibility Service API** — the same API used by Google's own TalkBack screen reader. It does not root your phone, does not use any unofficial APIs, and does not touch anything outside of what you authorize.

**Tech Stack:**
- Flutter — app framework
- Kotlin — native Android Accessibility Service
- Flutter Background Service — 24/7 schedule monitoring
- Full Screen Intent — wakes phone over lock screen
- AudioManager STREAM_ALARM — bypasses silent mode for alarm

---

## ⚠️ Disclaimer

ProxyAI is an independent student project. Not affiliated with Microsoft or Microsoft Teams. Use responsibly and in line with your university's attendance policies. If Teams updates their UI, the navigation may need an update — we'll push fixes as fast as possible.

---

## 👨‍💻 Built By

**Ahmad** — CS Final Year Student, COMSATS University Islamabad

---

## ⭐ Support

If ProxyAI saved your attendance — drop a ⭐ on GitHub. It means a lot.

Found a bug? Open an issue or reach out directly.

---

<div align="center">

*ProxyAI — because attendance should not require consciousness.*

</div>
