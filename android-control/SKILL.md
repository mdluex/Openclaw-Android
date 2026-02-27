---
name: phone-control
description: Control an Android phone via a proot Ubuntu environment inside Termux using shell scripts. Use when the user wants to interact with the phone, including opening apps, searching YouTube, sending WhatsApp messages, controlling WiFi/Bluetooth/brightness, making calls, sending SMS, taking screenshots, installing apps, or performing complex UI tasks via a visual agent. Triggers on any request involving phone automation, app launching, deep linking, system controls, or screen interaction.
---

# Phone Control

Autonomous control of an Android phone via a proot Ubuntu environment inside Termux using bash scripts. No Python needed.

## Critical Rules

- Use ONLY the bash scripts listed below.
- **DO NOT** use `am start` directly — use the scripts instead.
- **DO NOT** use `python3` — it is NOT installed.
- **DO NOT** use `which` command.
- **PREFER deep-link commands** over the visual agent when possible.

## Scripts

Two scripts are bundled in `scripts/`:

- **[phone_control.sh](scripts/phone_control.sh)** — Fast, direct commands (app launches, deep links, system controls)
- **[phone_agent.sh](scripts/phone_agent.sh)** — Visual agent for complex UI tasks with no direct command

## Smart Commands — Instant, No Navigation Needed

### App Launches

```bash
bash scripts/phone_control.sh open-app com.google.android.youtube
bash scripts/phone_control.sh open-app com.whatsapp
bash scripts/phone_control.sh open-app com.instagram.android
bash scripts/phone_control.sh open-app com.android.chrome
bash scripts/phone_control.sh open-app com.android.settings
```

### Deep Links (PREFERRED — skip UI navigation entirely!)

```bash
bash scripts/phone_control.sh youtube-search "lofi music"
bash scripts/phone_control.sh open-url "https://google.com"
bash scripts/phone_control.sh whatsapp-send 919876543210 "Hello from AI"
bash scripts/phone_control.sh playstore-search "Spotify"
bash scripts/phone_control.sh install-app com.spotify.music
```

### System Controls

```bash
bash scripts/phone_control.sh wifi on|off
bash scripts/phone_control.sh bluetooth on|off
bash scripts/phone_control.sh brightness 255
bash scripts/phone_control.sh battery
bash scripts/phone_control.sh call 9876543210
bash scripts/phone_control.sh send-sms 9876543210 "Hello"
bash scripts/phone_control.sh screenshot
```

## Visual Agent — For Complex UI Tasks Only

Use this ONLY when no smart command exists for the task.

```bash
bash scripts/phone_agent.sh "Your task description here"
```

Examples of tasks that NEED the visual agent:
- Navigating menus/settings with no direct command
- Reading content from the screen
- Complex multi-step interactions inside apps

## Decision Table

| Request | Best Command |
|---------|-------------|
| "Search YouTube for lofi" | `bash scripts/phone_control.sh youtube-search "lofi music"` |
| "Open YouTube" | `bash scripts/phone_control.sh open-app com.google.android.youtube` |
| "Open google.com" | `bash scripts/phone_control.sh open-url "https://google.com"` |
| "Send WhatsApp to 123" | `bash scripts/phone_control.sh whatsapp-send 123 "message"` |
| "Install Spotify" | `bash scripts/phone_control.sh playstore-search "Spotify"` |
| "Turn on WiFi" | `bash scripts/phone_control.sh wifi on` |
| "Battery level?" | `bash scripts/phone_control.sh battery` |
| "Enable Dark Mode" | `bash scripts/phone_agent.sh "Open Settings and enable Dark Mode"` |
| "Read notifications" | `bash scripts/phone_agent.sh "Open notifications and read them"` |
