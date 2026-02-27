# 📱 Android Control Skill

An OpenClaw skill that gives your AI agent full control over an Android phone from a **proot Ubuntu environment inside Termux**. It uses bash scripts to launch apps, send messages, control system settings, and perform complex UI automation via a visual agent powered by Gemini Vision.

## What's Included

```
android-control/
├── SKILL.md                    # Skill definition (triggers & instructions)
└── scripts/
    ├── phone_control.sh        # Direct commands (apps, deep links, system controls)
    └── phone_agent.sh          # Visual agent (screenshot → Gemini → actions loop)
```

### Smart Commands (`phone_control.sh`)

- **App launches** — Open any app by package name
- **Deep links** — YouTube search, WhatsApp messages, Play Store, URLs
- **System controls** — WiFi, Bluetooth, brightness, battery, calls, SMS, screenshots

### Visual Agent (`phone_agent.sh`)

- Takes a screenshot → sends to Gemini Vision → executes actions → repeats
- Handles complex multi-step UI tasks that have no direct command

## Installation

### Prerequisites

- [OpenClaw](https://github.com/nicekid1/OpenClaw) installed
- Android phone with Termux + proot Ubuntu
- Either **Wireless ADB** enabled or **root (su)** access

### Manual Installation

```bash
# Clone the repo (remove old clone if exists)
rm -rf ~/Openclaw-Android
git clone https://github.com/mdluex/Openclaw-Android.git ~/Openclaw-Android

# Navigate to your workspace
cd ~/.openclaw/workspace

# Create the skills directory (ignored if already exists)
mkdir -p skills

# Copy the skill (overwrites if already exists)
cp -rf ~/Openclaw-Android/android-control skills/android-control
```

### Quick One-Liner

```bash
rm -rf ~/Openclaw-Android && git clone https://github.com/mdluex/Openclaw-Android.git ~/Openclaw-Android && cd ~/.openclaw/workspace && mkdir -p skills && cp -rf ~/Openclaw-Android/android-control skills/android-control
```

### Verify Installation

Check that the skill is in place:

```bash
ls ~/.openclaw/workspace/skills/android-control/SKILL.md
```

OpenClaw will automatically detect the skill and trigger it when you ask anything related to android control, app launching, or system automation.

## Manual Testing

Run these commands from inside proot Ubuntu to test the scripts directly:

```bash
# Navigate to the skill folder
cd ~/.openclaw/workspace/skills/android-control

# --- Basic Tests ---

# Check battery level
bash scripts/phone_control.sh battery

# Take a screenshot
bash scripts/phone_control.sh screenshot

# Get device info
bash scripts/phone_control.sh info

# --- App Control ---

# Open YouTube
bash scripts/phone_control.sh open-app com.google.android.youtube

# Search YouTube for "lofi music"
bash scripts/phone_control.sh youtube-search "lofi music"

# Open a URL in Chrome
bash scripts/phone_control.sh open-url "https://google.com"

# Open WhatsApp
bash scripts/phone_control.sh open-app com.whatsapp

# Open Settings
bash scripts/phone_control.sh open-app com.android.settings

# --- System Controls ---

# Turn WiFi off then on
bash scripts/phone_control.sh wifi off
bash scripts/phone_control.sh wifi on

# Turn Bluetooth on
bash scripts/phone_control.sh bluetooth on

# Set brightness to max
bash scripts/phone_control.sh brightness 255

# Set brightness to low
bash scripts/phone_control.sh brightness 50

# --- Visual Agent (requires Gemini API key) ---

# Open Settings and enable Dark Mode
bash scripts/phone_agent.sh "Open Settings and enable Dark Mode"

# Read what's on screen
bash scripts/phone_agent.sh "Tell me what is currently on the screen"
```

## Usage with OpenClaw

Once installed, just talk to your OpenClaw agent:

- *"Open YouTube and search for lofi music"*
- *"Send a WhatsApp message to 123456789 saying hello"*
- *"Turn off WiFi"*
- *"What's my battery level?"*
- *"Enable dark mode"* (uses the visual agent)

## License

MIT
