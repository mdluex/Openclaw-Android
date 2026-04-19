---
name: phone-control
description: Professional Android automation skill running inside Termux proot. Uses a robust Local ADB bridge to control the device (screen, apps, intents) without root limitations. Supports self-healing connection logic. Best for: opening apps, UI automation, typing, deep linking (YouTube/Maps), and reading screen content via UI dump.
---

# 📱 Professional Phone Control Skill

This skill enables an AI agent running inside `proot Ubuntu` to control the host Android device via a local ADB bridge (`127.0.0.1:5555`).

## 🚀 Core Architecture
- **Environment:** Ubuntu (proot) running inside Termux app.
- **Bridge:** Uses Termux's native `adb` binary to connect to `localhost:5555`.
- **Stability:** Scripts include **auto-fix logic**. If ADB drops, it uses `su` (if available) to restart the ADB service automatically.

## 🛠️ Main Tools

Use the provided bash script for all interactions. **DO NOT** use raw `adb` or `su` commands directly.

**Script Path:** `~/.openclaw/workspace/skills/android-control/scripts/phone_control.sh`

### 1. 👀 See & Analyze (Do this first!)
Before tapping blindly, look at what's on the screen.

```bash
# Dump UI hierarchy to XML and read it (to find text/coordinates)
bash scripts/phone_control.sh dump-ui

# List user-installed apps (to find package names)
bash scripts/phone_control.sh list-apps
```

### 2. 👆 Navigation & Input

```bash
# Basic Navigation
bash scripts/phone_control.sh home
bash scripts/phone_control.sh back
bash scripts/phone_control.sh recent

# Interaction
bash scripts/phone_control.sh tap <x> <y>          # e.g., tap 500 1000
bash scripts/phone_control.sh swipe <x1> <y1> <x2> <y2> [ms] # e.g., swipe 500 1000 500 500
bash scripts/phone_control.sh type "Hello World"   # Type text (focus field first!)
bash scripts/phone_control.sh key <keycode>        # e.g., key 66 (ENTER), key 27 (CAMERA)
```

### 3. 📱 App Management & Deep Links

```bash
# Open App (by package name)
bash scripts/phone_control.sh open-app com.google.android.youtube

# Kill App
bash scripts/phone_control.sh kill-app com.google.android.youtube

# Smart Deep Links (Preferred over manual navigation)
bash scripts/phone_control.sh youtube-search "OpenClaw demo"
bash scripts/phone_control.sh playstore-search "Termux"
bash scripts/phone_control.sh open-url "https://google.com"
bash scripts/phone_control.sh call "0123456789"
```

## 🤖 Autonomous Agent (Visual)
For complex, multi-step tasks where you need a visual feedback loop, use the autonomous agent script.

```bash
bash scripts/phone_agent.sh "Open Settings and enable Dark Mode"
```

## 🔧 Troubleshooting & Maintenance

If commands fail with "ADB connection lost" or "Connection refused":

1. **Run the check:**
   ```bash
   bash scripts/phone_control.sh check-adb
   ```
2. **Force a fix** (Requires Root/SU on device):
   ```bash
   bash scripts/phone_control.sh fix-adb
   ```
   *This restarts the ADB TCP service on port 5555 using `su`.*

## 🛑 Best Practices
- **Always Check First:** Use `dump-ui` or `list-apps` before guessing coordinates or package names.
- **Wait for UI:** After opening an app, add `sleep 2` or `sleep 5` before interacting to allow loading.
- **Use Deep Links:** Prefer `youtube-search` over opening YouTube and typing manually. It's faster and less prone to UI changes.

## 🤔 Decision Logic: Web Fetch vs. UI Dump
When the goal is to **extract text/data** from a public URL, choose the right tool for the job.

- **Use `web_fetch` first:** For scraping text from articles, news sites, or simple web pages. It is extremely fast and efficient.
  ```
  [User]: Get the gold prices from goldbullioneg.com
  [Mdluex]: (Calls web_fetch tool with the URL)
  ```

- **Use `phone_control.sh` for visual tasks:** If `web_fetch` fails (e.g., the content is behind a login, is heavily dynamic with JavaScript, or you need to interact with buttons), then use the visual method.
  ```bash
  # 1. Open the page on the phone
  bash scripts/phone_control.sh open-url "https://example.com"
  sleep 5
  # 2. "See" the screen
  bash scripts/phone_control.sh dump-ui
  ```
