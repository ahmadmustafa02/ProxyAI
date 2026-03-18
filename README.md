# ProxyAI 🤖

**Automatically joins your Microsoft Teams classes while you sleep.**

ProxyAI is an Android app built for university students who struggle to wake up for early morning online classes. Set your class schedule once — ProxyAI handles the rest. It wakes your phone, opens Microsoft Teams, finds the meeting, joins it, and mutes your mic automatically. Then it alarms you so you can take over.

---

## How It Works

1. **Add your classes** — Enter class name, the exact Microsoft Teams channel name, day of week, and class time
2. **Go to sleep** — ProxyAI runs silently in the background 24/7
3. **5 minutes before class** — ProxyAI starts checking your Teams General channel every 30 seconds for a meeting link
4. **Automatic joining** — The moment a meeting is found, ProxyAI wakes your phone, opens Teams, navigates to the meeting, and joins with mic and camera off
5. **Wake up alarm** — A loud alarm bypasses silent mode to wake you up after joining so you can take over

---

## Features

- ✅ Fully automatic — zero interaction needed at join time
- ✅ Works while phone is asleep/screen off
- ✅ Joins with mic and camera off by default
- ✅ Checks for meeting link every 30 seconds before class
- ✅ Loud alarm after joining to wake the student
- ✅ Supports multiple classes and subjects
- ✅ Per-class on/off toggle
- ✅ Clean minimal black and white UI
- ✅ No Microsoft account login required
- ✅ No data sent to any server — everything runs locally on your device

---

## Requirements

- Android 8.0 (Oreo) or higher
- Microsoft Teams app installed and logged in on your phone
- No lock screen password — swipe only or no lock screen (required for automatic screen unlock)
- Accessibility Service permission enabled for ProxyAI
- Battery optimization disabled for ProxyAI

---

## Installation

### Step 1 — Disable Google Play Protect
1. Open **Play Store**
2. Tap your **profile picture** (top right)
3. Tap **Play Protect → Settings (gear icon)**
4. Turn OFF **"Scan apps with Play Protect"**
5. Turn OFF **"Improve harmful app detection"**

> You can re-enable Play Protect after installing if you wish.

### Step 2 — Install the APK
1. Download the ProxyAI APK file
2. Go to **Settings → Apps → Special app access → Install unknown apps**
3. Allow installation from your browser or file manager
4. Open the downloaded APK and tap Install

### Step 3 — Allow Restricted Settings
This step is required on Android 13 and above:
1. Go to **Settings → App Management → ProxyAI**
2. Tap the **three dots** (top right corner)
3. Tap **"Allow Restricted Settings"**

### Step 4 — Enable Accessibility Service
1. Open ProxyAI app
2. Tap **"Enable Now"** when prompted
3. In Accessibility settings find **ProxyAI** and toggle it ON

### Step 5 — Remove Lock Screen Password
ProxyAI needs to unlock your screen automatically while you sleep:
1. Go to **Settings → Biometrics and Security → Screen Lock**
2. Select **None** or **Swipe**

### Step 6 — Disable Battery Optimization
Prevents Android from killing ProxyAI in the background:
1. Go to **Settings → Apps → ProxyAI → Battery**
2. Select **Unrestricted**

---

## Adding Your Classes

1. Open ProxyAI and tap the **+** button
2. Fill in the following:
   - **Class Name** — e.g. "Computer Networks"
   - **Team Name** — the exact name as it appears in your Microsoft Teams app (e.g. "FA23-BCS Computer Networks")
   - **Days** — select which days this class occurs
   - **Time** — set the class start time
3. Make sure the toggle is **ON** for each class
4. That's it — ProxyAI will handle everything from here

> **Important:** The Team Name must match exactly as it appears in your Teams app. Check spelling carefully.

---

## How the Automation Works

ProxyAI uses Android's **Accessibility Service API** — the same API used by screen readers and assistive tools. It does not use any bots, servers, or third-party services. Everything happens directly on your device inside the Teams app:

```
Background Service monitors schedule
→ 5 mins before class: starts checking General channel every 30 seconds
→ Meeting link found: wakes phone screen
→ Dismisses swipe lock screen
→ Opens Microsoft Teams app
→ Navigates to your Team → General channel
→ Finds meeting post → Taps Join → Taps Join Now
→ Turns off mic and camera
→ Fires loud alarm to wake you up
```

---

## Privacy

- No Microsoft login required
- No user data collected or transmitted
- No backend server — everything runs on your device
- All class schedules stored locally only
- ProxyAI never reads your messages — it only navigates the Teams UI

---

## Troubleshooting

**App not joining at class time:**
- Make sure the toggle is ON for the class
- Check Team Name matches exactly
- Verify Accessibility Service is still enabled
- Make sure battery optimization is disabled

**"Restricted Setting" error when enabling Accessibility Service:**
- Go to Settings → App Management → ProxyAI → three dots → Allow Restricted Settings

**Teams opens but doesn't navigate:**
- Make sure screen lock is set to None or Swipe (no password/pattern)
- Make sure Microsoft Teams app is installed and you are logged in

**Alarm not loud enough:**
- Make sure media and alarm volume is turned up on your phone

---

## Known Limitations

- Requires no lock screen password for fully automatic operation
- If Microsoft Teams updates their UI, navigation may break until ProxyAI is updated
- iOS not supported — Android only
- Does not work if Teams app is not installed or logged out

---

## Tech Stack

- **Flutter** — cross platform mobile framework
- **Kotlin** — Android native code for Accessibility Service
- **Android Accessibility Service API** — UI automation inside Teams
- **Flutter Background Service** — 24/7 background schedule monitoring
- **Full Screen Intent** — wakes phone and shows over lock screen

---

## Disclaimer

ProxyAI is an independent student project and is not affiliated with Microsoft or Microsoft Teams in any way. Use responsibly and in accordance with your university's attendance policy.

---

## Contact

Built by Ahmad — CS Final Year Student, COMSATS University Islamabad

---

*ProxyAI — because 8am classes should not require being awake at 8am.*
