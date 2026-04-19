#!/bin/bash
# ============================================
# 📱 OpenClaw Phone Control Script (Optimized)
# Proot Ubuntu -> Termux Bridge via Local ADB
# ============================================

CMD="$1"
shift

# --- CONFIG ---
TERMUX_PREFIX="/data/data/com.termux/files/usr"
TERMUX_ADB="/data/data/com.termux/files/usr/bin/adb"
ADB_HOST="127.0.0.1"
ADB_PORT="5555"

# --- HELPER: Run Command via Local ADB ---
# Optimized: We assume connection is mostly stable to save hundreds of milliseconds per call.
run_cmd() {
  if [ ! -x "$TERMUX_ADB" ]; then
    echo "❌ Error: Termux ADB not found at $TERMUX_ADB"
    exit 1
  fi
  "$TERMUX_ADB" -s $ADB_HOST:$ADB_PORT shell "$@"
}

# --- COMMANDS ---
case "$CMD" in
  # === SYSTEM & NAVIGATION ===
  home)
    run_cmd "input keyevent 3"
    echo "🏠 Pressed Home"
    ;;
  back)
    run_cmd "input keyevent 4"
    echo "◀️ Pressed Back"
    ;;
  recent)
    run_cmd "input keyevent 187"
    echo "🔲 Pressed Recents"
    ;;
  screenshot)
    FILENAME="${1:-/sdcard/screenshot.png}"
    run_cmd "screencap -p '$FILENAME'"
    echo "📸 Screenshot saved: $FILENAME"
    ;;
  dump-ui)
    run_cmd "uiautomator dump /sdcard/window_dump.xml >/dev/null 2>&1 && cat /sdcard/window_dump.xml"
    ;;

  # === INTERACTION ===
  tap)
    run_cmd "input tap $1 $2"
    echo "👆 Tapped at ($1, $2)"
    ;;
  swipe)
    run_cmd "input swipe $1 $2 $3 $4 ${5:-300}"
    echo "👆 Swiped from ($1,$2) to ($3,$4)"
    ;;
  type)
    TEXT=$(echo "$*" | sed "s/'/\\'/g")
    TEXT_ESCAPED=$(echo "$TEXT" | sed 's/ /%s/g')
    run_cmd "input text '$TEXT_ESCAPED'"
    echo "⌨️ Typed: $*"
    ;;
  key)
    run_cmd "input keyevent $1"
    echo "🔘 Key pressed: $1"
    ;;

  # === APP CONTROL ===
  open-app)
    run_cmd "monkey -p $1 -c android.intent.category.LAUNCHER 1" >/dev/null 2>&1
    echo "📱 Opened: $1"
    ;;
  kill-app)
    run_cmd "am force-stop $1"
    echo "❌ Killed: $1"
    ;;
  list-apps)
    run_cmd "pm list packages -3" | sed 's/package://' | sort
    ;;

  # === INTENTS (Deep Links) ===
  youtube-search)
    QUERY=$(echo "$*" | sed 's/ /+/g')
    run_cmd "am start -a android.intent.action.VIEW -d 'https://www.youtube.com/results?search_query=$QUERY' com.google.android.youtube"
    echo "🔍 YouTube search: $*"
    ;;
  playstore-search)
    QUERY=$(echo "$*" | sed 's/ /+/g')
    run_cmd "am start -a android.intent.action.VIEW -d 'market://search?q=$QUERY'"
    echo "🔍 Play Store search: $*"
    ;;
  open-url)
    run_cmd "am start -a android.intent.action.VIEW -d '$1'"
    echo "🌐 Opened: $1"
    ;;
  call)
    run_cmd "am start -a android.intent.action.CALL -d tel:$1"
    echo "📞 Calling: $1"
    ;;

  # === UTILS ===
  check-adb)
    "$TERMUX_ADB" connect $ADB_HOST:$ADB_PORT >/dev/null 2>&1
    if "$TERMUX_ADB" -s $ADB_HOST:$ADB_PORT get-state >/dev/null 2>&1; then
        echo "✅ ADB Connected"
        exit 0
    else
        echo "❌ ADB Disconnected"
        exit 1
    fi
    ;;
  fix-adb)
    echo "🔧 Forcing ADB fix..."
    SU=""
    if [ -x /sbin/su ]; then SU=/sbin/su; elif [ -x /system/bin/su ]; then SU=/system/bin/su; elif [ -x /system/xbin/su ]; then SU=/system/xbin/su; fi
    if [ -n "$SU" ]; then
       env -i $SU -c "setprop service.adb.tcp.port $ADB_PORT && stop adbd && start adbd"
       sleep 3
       "$TERMUX_ADB" connect $ADB_HOST:$ADB_PORT >/dev/null 2>&1
       echo "✅ Fix applied."
    else
       echo "❌ SU not found."
       exit 1
    fi
    ;;
  *)
    echo "Usage: bash phone_control.sh [command] [args]"
    echo "Commands: home, back, screenshot, dump-ui, tap, swipe, type, open-app, list-apps, youtube-search, open-url, call"
    exit 1
    ;;
esac
  
  # === ADVANCED INTENTS ===
  send-email)
    # Usage: send-email "recipient@example.com" "Subject Line" "Body of the email."
    RECIPIENT="$1"
    SUBJECT="$2"
    BODY="$3"
    run_cmd "am start -a android.intent.action.SENDTO -d 'mailto:$RECIPIENT' --es android.intent.extra.SUBJECT '$SUBJECT' --es android.intent.extra.TEXT '$BODY'"
    echo "📧 Pre-filled email to $RECIPIENT"
    ;;

  *)
    # Updated usage to reflect new command
    echo "Usage: bash phone_control.sh [command] [args]"
    echo "Commands: home, back, screenshot, dump-ui, tap, swipe, type, open-app, list-apps, youtube-search, open-url, call, send-email"
    exit 1
    ;;
esac
