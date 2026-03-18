# ProxyAI 

<p align="center">
ProxyAI ensures you’re always present — joining your Microsoft Teams meetings automatically and waking you up at the perfect time to take over.

<p align="center">
  <img src="https://github.com/user-attachments/assets/e7779cfa-dbd8-4669-abd1-9245c9444133" width="180"/>
</p>

<p align="center">
  <strong>Never miss a class again — even in your sleep</strong>
</p>

<p align="center">
  ProxyAI joins your Microsoft Teams meetings at the exact class time—then rings a loud alarm one minute later so you can take over. Set your schedule once. Sleep in. Show up.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Platform-Android-3DDC84?style=for-the-badge&logo=android&logoColor=white" alt="Android" />
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/No%20backend-Local%20only-00D4FF?style=for-the-badge" alt="Local only" />
</p>

---

## Why ProxyAI?

Early morning online classes are brutal. You set the alarm, you still oversleep. You wake up, fumble for the phone, open Teams, find the meeting, join—and you're late.

**ProxyAI flips the script.** It joins the meeting for you at the exact class time, with mic and camera off. One minute later, a loud alarm wakes you up. You're already in the call; you just unmute and go.

- **Zero effort at join time** — Phone can be locked, screen off. ProxyAI wakes it, opens Teams, finds the team, joins the meeting, and mutes everything.
- **No Microsoft login in the app** — You stay logged in to Teams on your phone; ProxyAI uses Android automation to navigate the app.
- **Fully local** — No servers, no accounts, no data sent anywhere. Your schedule and behavior stay on your device.
- **Built for students** — One-tap setup, clear permissions, and a dark UI that doesn’t get in the way.

---

## How It Works

```
You add a class (name, Teams channel name, day, time)
         ↓
ProxyAI runs in the background 24/7
         ↓
At the exact class time → Wakes phone, opens Teams
         ↓
Finds your Team → General channel → "Meeting started" → Join
         ↓
Joins with mic & camera off
         ↓
1 minute later → Loud alarm until you tap "I'm awake"
         ↓
You take over. Already in the call.
```

| Step | What happens |
|------|----------------|
| **Schedule** | You add each class once: class name, exact Team name (as in Teams), days, and time. |
| **Background** | A foreground service checks the schedule every minute. No polling of Teams until class time. |
| **Class time** | At the exact minute of class, ProxyAI wakes the screen, dismisses swipe lock, and launches Teams. |
| **Navigation** | An Accessibility Service finds your Team (scrolling the list if needed), opens General, finds the "Meeting started" banner, and taps Join. |
| **Pre-join** | Mic and camera are turned off; then it taps Join now. |
| **Alarm** | One minute after class time, a full-volume alarm rings and keeps ringing until you tap **I'm awake** in the notification. |

---

## Features

| | |
|---|---|
| **Automatic join** | Joins at the exact class time—no "5 minutes before" window. |
| **Works while asleep** | Screen off, phone locked (swipe-only). ProxyAI wakes and unlocks for the flow. |
| **Mic & camera off** | Joins with microphone and camera disabled by default. |
| **Loud alarm** | Alarm uses the alarm stream and audio focus so it’s audible even with Teams in the foreground. |
| **Rings until you respond** | Alarm loops until you tap **I'm awake** in the notification. |
| **Multiple classes** | Add as many classes as you need; each has its own toggle. |
| **No backend** | Everything runs on device. No accounts, no cloud, no data collection. |
| **Dark UI** | Simple, modern interface with clear status and controls. |

---

## Requirements

- **Android 8.0 (Oreo)** or higher  
- **Microsoft Teams** installed and logged in on the same device  
- **Swipe-only (or no) lock screen** — no PIN/pattern/password for full automation  
- **ProxyAI Accessibility Service** enabled in system settings  
- **Battery optimization** disabled for ProxyAI (so the background checker keeps running)  
- **Allow restricted settings** (Android 13+) so the app can use Accessibility and background execution  

---

## Installation

### 1. Install the APK

- Download the ProxyAI APK. (from release)
- If needed: **Settings → Apps → Special app access → Install unknown apps** and allow your browser or file manager.  
- Open the APK and install.  

*If Play Protect blocks it:* Play Store → Profile → Play Protect → Settings → turn off "Scan apps with Play Protect" and Improve Harmful App Detection for installation, then re-enable if you like afterward.

### 2. Allow restricted settings (Android 13+)

1. **Settings** → search **App management** (or **Apps**).  
2. Find **ProxyAI** → tap the **⋮** menu → **Allow restricted settings**.  

### 3. First launch and permissions

1. Open ProxyAI. Complete the short onboarding.  
2. When asked, tap **Open Settings** and enable the **ProxyAI** Accessibility Service.  
3. When asked, disable **Battery optimization** for ProxyAI (e.g. **Unrestricted**).  
4. Optional but recommended: **Settings → App management → ProxyAI → Manage notifications** → allow notifications (for the "I'm awake" alarm notification).  

### 4. Lock screen

For automatic unlock during the flow, use **Swipe** or **None** (no PIN/pattern/password).  
Configure in **Settings → Security / Biometrics → Screen lock**.  

---

## Adding a class

1. In ProxyAI, tap **Add class** (or the + button).  
2. Fill in:  
   - **Class name** — e.g. *Computer Networks* (for your reference).  
   - **Team name** — **exactly** as it appears in the Teams app (e.g. *FA23-BCS Computer Networks*).  
   - **Days** — the weekdays this class runs.  
   - **Time** — class start time.  
3. Save and leave the class **enabled** (toggle on).  

The **Team name** must match the Teams channel name character-for-character; otherwise the automation may not find it.

---

## How the automation works (technical)

ProxyAI uses **Android’s Accessibility Service API** (the same family of APIs used by screen readers and accessibility tools). There are no remote bots or servers:

- A **foreground service** and **AlarmManager** run a schedule check every minute.  
- At the **exact class minute**, the app triggers a **full-screen intent** and starts a transparent activity to wake the device and dismiss the keyguard (swipe lock).  
- It launches **Microsoft Teams** via the system launcher.  
- The **Accessibility Service** inspects the Teams UI, finds the team by name (scrolling the list if needed), opens **General**, finds the **"Meeting started"** banner, and taps **Join**.  
- On the pre-join screen it turns off mic and camera, then taps **Join now**.  
- One minute after class time, **AlarmRingingService** starts: it requests **audio focus** with `USAGE_ALARM`, plays the default alarm sound in a **loop** via `MediaPlayer`, and shows an **ongoing notification** with an **I'm awake** action.  
- Tapping **I'm awake** stops the service, releases audio focus, and clears the pending automation state.  

All logic runs on the device; no Microsoft or third-party backend is involved.

---

## Privacy

- No Microsoft or other account login inside ProxyAI.  
- No user data collected or sent off-device.  
- No backend server; schedules and state are stored locally (e.g. SharedPreferences).  
- The Accessibility Service only interacts with the Teams UI to perform the described actions; it does not read or upload your messages or content.  

---

## Troubleshooting

| Issue | What to try |
|-------|-------------|
| **Doesn’t join at class time** | Confirm the class is enabled, Team name matches Teams exactly, Accessibility is on, and battery optimization is off for ProxyAI. |
| **"Restricted setting" when enabling Accessibility** | Complete **Allow restricted settings** for ProxyAI (Settings → App management → ProxyAI → ⋮ → Allow restricted settings). |
| **Teams opens but doesn’t navigate** | Use swipe-only or no lock screen; ensure Teams is installed and you’re logged in. |
| **Alarm too quiet** | Device alarm volume and (if applicable) media volume should be up; the app requests alarm stream and audio focus. |
| **Alarm stops after one ring** | In current versions the alarm loops until you tap **I'm awake**; if it still stops, check that you’re on the latest build. |

---

## Limitations

- **Android only** — iOS is not supported.  
- **Lock screen** — Full automation requires swipe or no lock; PIN/pattern/password prevent automatic unlock.  
- **Teams UI** — If Microsoft changes the Teams app layout or strings, automation may need an update.  
- **Teams must be installed and logged in** — The app only drives the existing Teams client.  

---

## Tech stack

- **Flutter** — UI and app logic.  
- **Kotlin** — Android: Accessibility Service, AlarmManager, foreground service, full-screen intent, wake/unlock, alarm playback.  
- **flutter_background_service** — Foreground task that keeps the schedule checker eligible to run.  
- **Local storage** — Schedules and flags in SharedPreferences; no cloud.  

---

## Disclaimer

ProxyAI is an independent project and is not affiliated with or endorsed by Microsoft or Microsoft Teams. Use it in line with your institution’s policies and your own responsibility.  

---

<p align="center">
  <strong>ProxyAI</strong> — Your AI Proxy for online classes
</p>

<p align="center">
  <sub>Built with Flutter · Android</sub>
</p>
