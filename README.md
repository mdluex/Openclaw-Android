# 📱 Android Control Skill

An OpenClaw skill that gives your AI agent full control over an Android phone from a **proot Ubuntu environment inside Termux**. It uses a **Local ADB bridge** (`127.0.0.1:5555`) to launch apps, navigate the UI, send messages, perform deep links, and handle complex multi-step UI automation via a visual agent powered by Gemini Vision.

## What's Included

```
android-control/
├── SKILL.md                    # Skill definition (triggers & instructions)
├── SOUL.md                     # Agent personality & behavior rules
└── scripts/
    ├── phone_control.sh        # Direct commands (apps, deep links, UI interaction)
    └── phone_agent.sh          # Visual agent (screenshot → Gemini → actions loop)
```

### Smart Commands (`phone_control.sh`)

- **Navigation** — Home, Back, Recents
- **UI Interaction** — Tap, swipe, type text, key events
- **App control** — Open/kill apps, list installed apps
- **Deep links** — YouTube search, Play Store search, open URLs, make calls, send emails
- **Screen analysis** — Screenshots, UI hierarchy dump (`dump-ui`)
- **ADB maintenance** — Connection check and self-healing fix

### Visual Agent (`phone_agent.sh`)

- Takes a screenshot + dumps UI → sends to Gemini Vision → executes actions → repeats
- Uses `gemini-2.5-pro` for smarter decision-making
- Optimized with parallel screencap/UI dump and Python-based JSON handling

### SOUL.md

- Defines the agent's personality, behavior rules, and operational boundaries
- Installed to the workspace root so the agent loads it on every session

## 🚀 Full System Setup (From Scratch)

If you are starting from a completely fresh phone, follow this step-by-step guide to get Termux, proot Ubuntu, OpenClaw, and the Android Control skill running.

### Step 1: Install Termux & Proot Ubuntu

1. Download and install **Termux** from [F-Droid](https://f-droid.org/packages/com.termux/) (Do not use the Google Play version).
2. Open Termux and run the following commands to update and install `proot-distro`:

```bash
pkg update -y && pkg upgrade -y
pkg install proot-distro -y
```

3. Install and log into Ubuntu:

```bash
proot-distro install ubuntu
proot-distro login ubuntu
```

### Step 2: Install Node.js & Python inside Ubuntu

Once inside the `root@localhost:~#` Ubuntu prompt, install the required dependencies:

```bash
apt update && apt upgrade -y
apt install curl git build-essential python3 python3-pip -y

# Install Node.js
curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
apt install -y nodejs
```

### Step 3: Install OpenClaw

Clone and set up [OpenClaw](https://github.com/openclaw/openclaw) from its official repository:

```bash
# Clone the Core OpenClaw repository
git clone https://github.com/openclaw/openclaw.git ~/.openclaw-core
cd ~/.openclaw-core

# Install OpenClaw
npm install -g pnpm
pnpm install
pnpm openclaw setup
pnpm ui:build
```

### Step 4: Setup Local ADB

To allow the AI to control your phone, you must enable Local ADB.

1. On your phone, go to **Settings > About Phone** and tap **Build Number** 7 times to enable Developer Options.
2. Go to **Settings > Developer Options** and enable **USB Debugging** and **Wireless Debugging**.
3. Open a *new* Termux session (swipe from left margin > New Session, outside of Ubuntu) and run:

```bash
pkg install android-tools -y
# Start ADB on port 5555
su -c "setprop service.adb.tcp.port 5555 && stop adbd && start adbd"
adb connect 127.0.0.1:5555
```

### Step 5: Install the Android Control Skill

Return to your `proot-distro login ubuntu` session and run the one-liner to install this skill:

```bash
rm -rf ~/Openclaw-Android && git clone https://github.com/mdluex/Openclaw-Android.git ~/Openclaw-Android && cd ~/.openclaw/workspace && mkdir -p skills && cp -rf ~/Openclaw-Android/android-control skills/android-control && cp ~/.openclaw/workspace/SOUL.md ~/.openclaw/workspace/SOUL.md.backup 2>/dev/null || true && cp -f ~/Openclaw-Android/android-control/SOUL.md ~/.openclaw/workspace/SOUL.md
```

### Step 6: Start OpenClaw

Start your OpenClaw agent, and it will automatically load the `android-control` skill from the workspace:

```bash
# From inside ~/.openclaw-core
pnpm gateway:watch
```

Now you can chat with your agent (usually at `http://localhost:3000` or via the gateway) and ask it to open apps, search YouTube, or toggle system settings!

---

## ⚡ Skill Installation Only

If you already have OpenClaw running and just want to install the skill:

### Prerequisites

- [OpenClaw](https://github.com/openclaw/openclaw) installed
- Android phone with Termux + proot Ubuntu
- **Local ADB** enabled on port 5555 (see [ADB Setup](#adb-setup) below)
- `python3` installed in proot Ubuntu (used by the visual agent)

### Manual Installation

> **⚠️ Note:** Installing this skill will overwrite your existing `SOUL.md` file. The commands below automatically create a backup (`SOUL.md.backup`).

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

# Backup existing SOUL.md before overwriting
cp ~/.openclaw/workspace/SOUL.md ~/.openclaw/workspace/SOUL.md.backup 2>/dev/null || true

# Copy new SOUL.md to the workspace root
cp -f ~/Openclaw-Android/android-control/SOUL.md ~/.openclaw/workspace/SOUL.md
```

### Quick One-Liner

```bash
rm -rf ~/Openclaw-Android && git clone https://github.com/mdluex/Openclaw-Android.git ~/Openclaw-Android && cd ~/.openclaw/workspace && mkdir -p skills && cp -rf ~/Openclaw-Android/android-control skills/android-control && cp SOUL.md SOUL.md.backup 2>/dev/null || true && cp -f ~/Openclaw-Android/android-control/SOUL.md SOUL.md
```

### Reverting `SOUL.md`

If you ever want to restore your old configuration, simply run:

```bash
cd ~/.openclaw/workspace
mv SOUL.md.backup SOUL.md
```

### Verify Installation

Check that everything is in place:

```bash
ls ~/.openclaw/workspace/skills/android-control/SKILL.md
ls ~/.openclaw/workspace/SOUL.md
```

OpenClaw will automatically detect the skill and trigger it when you ask anything related to android control, app launching, or system automation.

### ADB Setup

The skill requires a Local ADB connection on port 5555. To set it up:

```bash
# In Termux (not proot), enable ADB over TCP
su -c "setprop service.adb.tcp.port 5555 && stop adbd && start adbd"

# Connect ADB to localhost
adb connect 127.0.0.1:5555
```

If ADB drops, you can fix it from inside proot using:

```bash
bash scripts/phone_control.sh fix-adb
```

## Manual Testing

Run these commands from inside proot Ubuntu to test the scripts directly:

```bash
# Navigate to the skill folder
cd ~/.openclaw/workspace/skills/android-control

# --- ADB Check ---

# Verify ADB connection
bash scripts/phone_control.sh check-adb

# Fix ADB if disconnected (requires root)
bash scripts/phone_control.sh fix-adb

# --- Navigation ---

# Press Home / Back / Recents
bash scripts/phone_control.sh home
bash scripts/phone_control.sh back
bash scripts/phone_control.sh recent

# --- Screen Analysis ---

# Take a screenshot
bash scripts/phone_control.sh screenshot

# Dump UI hierarchy (see all on-screen elements with coordinates)
bash scripts/phone_control.sh dump-ui

# --- App Control ---

# Open YouTube
bash scripts/phone_control.sh open-app com.google.android.youtube

# Kill an app
bash scripts/phone_control.sh kill-app com.google.android.youtube

# List installed apps
bash scripts/phone_control.sh list-apps

# --- Deep Links ---

# Search YouTube for "lofi music"
bash scripts/phone_control.sh youtube-search "lofi music"

# Search Play Store
bash scripts/phone_control.sh playstore-search "Termux"

# Open a URL in Chrome
bash scripts/phone_control.sh open-url "https://google.com"

# Make a phone call
bash scripts/phone_control.sh call 0123456789

# --- UI Interaction ---

# Tap at coordinates
bash scripts/phone_control.sh tap 540 1000

# Swipe down
bash scripts/phone_control.sh swipe 540 500 540 1500

# Type text (focus a text field first)
bash scripts/phone_control.sh type "Hello World"

# --- Visual Agent (requires Gemini API key + python3) ---

# Open Settings and enable Dark Mode
bash scripts/phone_agent.sh "Open Settings and enable Dark Mode"

# Read what's on screen
bash scripts/phone_agent.sh "Tell me what is currently on the screen"
```

## Usage with OpenClaw

Once installed, just talk to your OpenClaw agent:

- *"Open YouTube and search for lofi music"*
- *"Send a WhatsApp message to 123456789 saying hello"*
- *"What apps are installed?"*
- *"Enable dark mode"* (uses the visual agent)
- *"Open google.com and read the page"*

## License

MIT
