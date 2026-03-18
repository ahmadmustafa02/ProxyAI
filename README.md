
# ProxyAI 🤖

**Automatically joins your Microsoft Teams classes while you sleep.**

ProxyAI is an Android app built for university students who struggle to wake up for early morning online classes. Set your class schedule once — ProxyAI handles the rest. It wakes your phone, opens Microsoft Teams, finds the meeting, joins it, and mutes your mic automatically. Then it alarms you so you can take over.

---

## How It Works

1. **Add your classes** — Enter class name, the exact Microsoft Teams channel name, day of week, and class time
2. **Go to sleep** — ProxyAI runs silently in the background 24/7
3. **5 minutes before class** — ProxyAI wakes your phone and opens Microsoft Teams
4. **Automatic navigation** — The app navigates to your Team's General channel, finds the meeting post, and joins the meeting with mic and camera off
5. **Wake up alarm** — A loud alarm bypasses silent mode to wake you up after joining

---

## Features

- ✅ Fully automatic — zero interaction needed at join time
- ✅ Works while phone is asleep/screen off
- ✅ Joins with mic and camera off by default
- ✅ Loud alarm after joining to wake the student
- ✅ Supports multiple classes and subjects
- ✅ Per-class on/off toggle
- ✅ No Microsoft account login required
- ✅ No data sent to any server — everything runs locally on your device

---

## Requirements

- Android 8.0 (Oreo) or higher
- Microsoft Teams app installed and logged in
- No lock screen password (swipe only or no lock) — required for automatic screen unlock
- Accessibility Service permission enabled for ProxyAI
- Battery optimization disabled for ProxyAI

---

## Installation

Since ProxyAI is not on the Play Store yet, install it directly:

1. Download the APK file
2. On your Android phone go to **Settings → Apps → Special app access → Install unknown apps**
3. Allow installation from your browser or file manager
4. Open the downloaded APK and install
5. Follow the in-app setup instructions

---

## Setup Guide

### Step 1 — Remove Lock Screen Password
ProxyAI needs to unlock your screen automatically. Go to:
**Settings → Biometrics and Security → Screen Lock → None**

### Step 2 — Enable Accessibility Service
ProxyAI uses Android Accessibility Service to navigate Teams automatically. When prompted, tap **Enable Now** and toggle ProxyAI on in the Accessibility settings.

### Step 3 — Disable Battery Optimization
Prevents Android from killing the background service:
**Settings → Apps → ProxyAI → Battery → Unrestricted**

### Step 4 — Add Your Classes
Tap the **+** button on the home screen and fill in:
- **Class Name** — e.g. Computer Networks
- **Team Name** — exact name as it appears in your Teams app (e.g. "FA23-BCS Computer Networks")
- **Days** — select which days the class occurs
- **Time** — set the class start time

### Step 5 — Enable the Toggle
Make sure the toggle is ON for each class you want ProxyAI to auto-join.

---

## How the Automation Works

ProxyAI uses Android's **Accessibility Service API** — the same API used by screen readers and assistive tools. It does not use any bots, servers, or third-party services. Everything happens directly on your device inside the Teams app:

```
Background Service → Wakes phone → Opens Teams app
→ Navigates to your Team → General channel
→ Finds "Scheduled a meeting" post
→ Taps meeting card → Taps Join → Taps Join Now
→ Turns off mic → Fires alarm
```

---

## Privacy

- No Microsoft login required
- No user data collected or transmitted
- No backend server
- All class schedules stored locally on your device only
- ProxyAI never reads your messages — it only navigates the Teams UI

---

## Known Limitations

- Requires no lock screen password for fully automatic operation
- If Microsoft Teams updates their UI layout, navigation may break until ProxyAI is updated
- iOS is not supported (Android only)
- Does not work if Teams app is not installed or logged out

---

## Tech Stack

- **Flutter** — cross-platform mobile framework
- **Kotlin** — Android native code for Accessibility Service
- **Android Accessibility Service API** — UI automation
- **Flutter Background Service** — 24/7 background monitoring
- **Microsoft Teams** — target app for automation

---

## Contributing

This project is currently in early testing. If you find bugs or have suggestions:
- Open an issue on GitHub
- Or reach out directly via the contact below

---

## Disclaimer

ProxyAI is an independent student project and is not affiliated with Microsoft or Microsoft Teams in any way. Use responsibly and in accordance with your university's attendance policy.

---

## Contact

Built by Ahmad Mustafa 

---

*ProxyAI*
