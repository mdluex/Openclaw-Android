#!/bin/bash
# ============================================
# OpenClaw Phone Control Script (Proot Ubuntu → Termux Bridge)
# Run via: bash phone_control.sh <command> [args]
# Works from inside proot Ubuntu by bridging commands to Termux/Android
# ============================================

CMD="$1"
shift

# Termux paths accessible from inside proot
TERMUX_PREFIX="/data/data/com.termux/files/usr"
TERMUX_BIN="$TERMUX_PREFIX/bin"

# Auto-detect the best method to run Android commands from proot
# Cached in RUN_METHOD to avoid re-detecting on every call
detect_method() {
  if [ -n "$RUN_METHOD" ]; then return; fi

  # 1. ADB wireless debugging (most reliable from proot)
  if [ -x "$TERMUX_BIN/adb" ] && "$TERMUX_BIN/adb" get-state 1>/dev/null 2>&1; then
    RUN_METHOD="adb"
  # 2. Magisk su (usually at /sbin/su)
  elif [ -x /host-rootfs/sbin/su ]; then
    RUN_METHOD="magisk"
  # 3. Legacy su paths (SuperSU / older roots)
  elif [ -x /host-rootfs/system/xbin/su ]; then
    RUN_METHOD="system_xbin"
  elif [ -x /host-rootfs/system/bin/su ]; then
    RUN_METHOD="system_bin"
  else
    echo "❌ Error: Cannot reach Android from proot."
    echo ""
    echo "   Fix: Enable Wireless ADB (recommended):"
    echo "   1. Settings → Developer Options → Wireless Debugging → ON"
    echo "   2. Tap 'Pair device with pairing code' and note the IP:PORT + code"
    echo "   3. In Termux (not proot), run:"
    echo "      adb pair <IP:PORT> <CODE>"
    echo "      adb connect <IP:PORT>"
    echo "   4. Then re-enter proot and try again."
    exit 1
  fi
}

# Run a command on Android from inside proot Ubuntu
run_cmd() {
  detect_method
  case "$RUN_METHOD" in
    adb)         "$TERMUX_BIN/adb" shell "$@" ;;
    magisk)      /host-rootfs/sbin/su -c "$@" ;;
    system_xbin) /host-rootfs/system/xbin/su -c "$@" ;;
    system_bin)  /host-rootfs/system/bin/su -c "$@" ;;
  esac
}

case "$CMD" in

  # === SCREEN CONTROL ===
  screenshot)
    FILENAME="${1:-/sdcard/screenshot_$(date +%s).png}"
    run_cmd "screencap '$FILENAME'"
    echo "📸 Screenshot saved: $FILENAME"
    ;;

  tap)
    run_cmd "input tap $1 $2"
    echo "👆 Tapped at ($1, $2)"
    ;;

  swipe)
    run_cmd "input swipe $1 $2 $3 $4 ${5:-300}"
    echo "👆 Swiped from ($1,$2) to ($3,$4)"
    ;;

  type)
    run_cmd "input text '$*'"
    echo "⌨️ Typed: $*"
    ;;

  key)
    run_cmd "input keyevent $1"
    echo "🔘 Key pressed: $1"
    ;;

  # === APP CONTROL ===
  open-app)
    run_cmd "monkey -p $1 -c android.intent.category.LAUNCHER 1" 2>/dev/null
    echo "📱 Opened: $1"
    ;;

  kill-app)
    run_cmd "am force-stop $1"
    echo "❌ Killed: $1"
    ;;

  list-apps)
    run_cmd "pm list packages -3" | sed 's/package://' | sort
    ;;

  install-app)
    # Usage: install-app <package_id> (e.g., com.instagram.android)
    run_cmd "am start -a android.intent.action.VIEW -d 'market://details?id=$1'"
    echo "📦 Opened Play Store for: $1"
    echo "💡 Now tap the Install button (usually around tap 540 1350)"
    ;;

  playstore-search)
    # Usage: playstore-search <query>
    QUERY=$(echo "$*" | sed 's/ /+/g')
    run_cmd "am start -a android.intent.action.VIEW -d 'market://search?q=$QUERY'"
    echo "🔍 Searched Play Store for: $*"
    ;;

  youtube-search)
    # Usage: youtube-search <query>
    QUERY=$(echo "$*" | sed 's/ /+/g')
    run_cmd "am start -a android.intent.action.VIEW -d 'https://www.youtube.com/results?search_query=$QUERY' com.google.android.youtube"
    echo "🔍 YouTube search: $*"
    ;;

  open-url)
    # Usage: open-url <url>
    run_cmd "am start -a android.intent.action.VIEW -d '$1'"
    echo "🌐 Opened: $1"
    ;;

  whatsapp-send)
    # Usage: whatsapp-send <number> <message>
    NUM="$1"; shift; MSG=$(echo "$*" | sed 's/ /%20/g')
    run_cmd "am start -a android.intent.action.VIEW -d 'https://wa.me/$NUM?text=$MSG'"
    echo "📱 WhatsApp to $NUM"
    ;;

  # === SETTINGS CONTROL ===
  wifi)
    case "$1" in
      on)  run_cmd "svc wifi enable"  && echo "📶 WiFi ON" ;;
      off) run_cmd "svc wifi disable" && echo "📶 WiFi OFF" ;;
      *)   echo "Usage: wifi on|off" ;;
    esac
    ;;

  bluetooth)
    case "$1" in
      on)  run_cmd "svc bluetooth enable"  && echo "🔵 Bluetooth ON" ;;
      off) run_cmd "svc bluetooth disable" && echo "🔵 Bluetooth OFF" ;;
      *)   echo "Usage: bluetooth on|off" ;;
    esac
    ;;

  airplane)
    case "$1" in
      on)  run_cmd "cmd connectivity airplane-mode enable" && echo "✈️ Airplane Mode ON" ;;
      off) run_cmd "cmd connectivity airplane-mode disable" && echo "✈️ Airplane Mode OFF" ;;
    esac
    ;;

  brightness)
    run_cmd "settings put system screen_brightness $1"
    echo "🔆 Brightness set to $1/255"
    ;;

  # === UTILS ===
  send-sms)
    # Usage: send-sms <number> <message>
    NUM="$1"; shift; MSG="$*"
    # Note: Using intent needs user to tap send. Direct SMS usually needs privileges.
    run_cmd "am start -a android.intent.action.SENDTO -d sms:$NUM --es sms_body '$MSG'"
    echo "📩 SMS Compose opened for $NUM"
    ;;

  call)
    run_cmd "am start -a android.intent.action.CALL -d tel:$1"
    echo "📞 Calling: $1"
    ;;

  battery)
    run_cmd "dumpsys battery" | grep "level"
    ;;

  info)
    echo "Android Version: $(run_cmd 'getprop ro.build.version.release')"
    echo "Model: $(run_cmd 'getprop ro.product.model')"
    ;;

  connect-adb)
    # Helper to connect wireless debugging
    # Usage: connect-adb IP:PORT
    if [ -z "$1" ]; then
      echo "Usage: connect-adb <IP:PORT> (from Wireless Debugging setting)"
    else
      adb connect "$1"
    fi
    ;;

  *)
    echo "Usage: bash phone_control.sh [command] [args]"
    echo "Commands: screenshot, tap, swipe, type, key, open-app, install-app, etc."
    exit 1
    ;;
esac
