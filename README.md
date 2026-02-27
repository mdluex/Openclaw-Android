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

### Option 1: Shared Installation (all agents)

```bash
# Clone the repo
git clone https://github.com/YOUR_USERNAME/Openclaw-Phone.git

# Create the shared skills directory if it doesn't exist
mkdir -p ~/.openclaw/skills

# Copy the skill
cp -r Openclaw-Phone/android-control ~/.openclaw/skills/android-control
```

### Option 2: Agent-Specific Installation (single workspace)

```bash
# Clone the repo
git clone https://github.com/YOUR_USERNAME/Openclaw-Phone.git

# Navigate to your workspace
cd /path/to/your/workspace

# Create the skills directory if it doesn't exist
mkdir -p skills

# Copy the skill
cp -r /path/to/Openclaw-Phone/android-control skills/android-control
```

### Quick One-Liner (shared)

```bash
git clone https://github.com/YOUR_USERNAME/Openclaw-Phone.git && mkdir -p ~/.openclaw/skills && cp -r Openclaw-Phone/android-control ~/.openclaw/skills/android-control
```

### Verify Installation

Check that the skill is in place:

```bash
# Shared
ls ~/.openclaw/skills/android-control/SKILL.md

# OR Agent-specific
ls <workspace>/skills/android-control/SKILL.md
```

OpenClaw will automatically detect the skill and trigger it when you ask anything related to phone control, app launching, or system automation.

## Usage Examples

Once installed, just talk to your OpenClaw agent:

- *"Open YouTube and search for lofi music"*
- *"Send a WhatsApp message to 123456789 saying hello"*
- *"Turn off WiFi"*
- *"What's my battery level?"*
- *"Enable dark mode"* (uses the visual agent)

## License

MIT
