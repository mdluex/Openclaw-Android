#!/bin/bash
# ============================================
# 🤖 Autonomous Phone Agent (Optimized Fast Version)
# ============================================

# --- CONFIG ---
TERMUX_ADB="/data/data/com.termux/files/usr/bin/adb"
ADB_HOST="127.0.0.1"
ADB_PORT="5555"

MODEL="gemini-2.5-pro" # switch to a smarter model to avoid stupid loops
MAX_STEPS=15

REMOTE_SCREEN="/sdcard/agent_screen.png"
REMOTE_XML="/sdcard/ui.xml"
LOCAL_SCREEN="agent_screen.png"
LOCAL_XML="ui_local.xml"
PAYLOAD_FILE="agent_payload.json"
RESPONSE_FILE="agent_response.json"

# Optimized fast ADB command (skips connection checks to save time)
run_cmd() {
  "$TERMUX_ADB" -s $ADB_HOST:$ADB_PORT shell "$@"
}

pull_file() {
    "$TERMUX_ADB" -s $ADB_HOST:$ADB_PORT pull "$1" "$2" >/dev/null 2>&1
}

load_api_key() {
    if [ -n "$GEMINI_API_KEY" ]; then echo "$GEMINI_API_KEY"; return; fi
    local AUTH_FILE="$HOME/.openclaw/agents/main/agent/auth-profiles.json"
    if [ -f "$AUTH_FILE" ]; then
        grep -o '"key"[[:space:]]*:[[:space:]]*"[^"]*"' "$AUTH_FILE" | head -1 | sed 's/.*"key"[[:space:]]*:[[:space:]]*"//;s/"$//'
    fi
}

# Ensure ADB is connected ONCE at the start, not every command
check_adb() {
    if ! "$TERMUX_ADB" -s $ADB_HOST:$ADB_PORT get-state >/dev/null 2>&1; then
        echo "⚠️ Reconnecting ADB..."
        "$TERMUX_ADB" connect $ADB_HOST:$ADB_PORT >/dev/null 2>&1
    fi
}

do_action() {
    local ATYPE="$1"
    case "$ATYPE" in
        tap)      run_cmd "input tap $2 $3" ;; 
        swipe)    run_cmd "input swipe $2 $3 $4 $5 ${6:-150}" ;; # Faster swipe by default
        type)     run_cmd "input text '$(echo "$2" | sed 's/ /%s/g')'" ;;
        key)      run_cmd "input keyevent $2" ;;
        open_app) run_cmd "monkey -p $2 -c android.intent.category.LAUNCHER 1" ;;
        wait)     sleep "${2:-0.5}" ;; # Shorter default wait
        home)     run_cmd "input keyevent 3" ;;
        back)     run_cmd "input keyevent 4" ;;
        done)     echo "✅ Goal Achieved: $2"; exit 0 ;;
    esac
}

if [ -z "$1" ]; then
    echo "Usage: bash phone_agent.sh \"<task>\""
    exit 0
fi

TASK="$*"
API_KEY=$(load_api_key)

if [ -z "$API_KEY" ]; then
    echo "❌ No API key found."
    exit 1
fi

echo "🤖 FAST PHONE AGENT: $TASK"
check_adb

for STEP in $(seq 1 $MAX_STEPS); do
    echo "\n── STEP $STEP/$MAX_STEPS ──"

    # Optimization: Combine screenshot and dump into one shell call, then pull both.
    # We pipe uiautomator dump to cat so we don't even need to pull the XML file!
    run_cmd "screencap -p $REMOTE_SCREEN" >/dev/null 2>&1 &
    SCREENCAP_PID=$!
    
    # Get XML directly via stdout, bypassing the pull command for XML
    UI_XML=$(run_cmd "uiautomator dump /dev/tty >/dev/null 2>&1 && cat /sdcard/window_dump.xml 2>/dev/null")
    
    wait $SCREENCAP_PID
    pull_file "$REMOTE_SCREEN" "$LOCAL_SCREEN"

    # Prepare payload directly in python, reading UI_XML from environment variable
    export UI_XML
    python3 -c "
import json, sys, base64, os

task = '''$TASK'''

try:
    if os.path.exists('$LOCAL_SCREEN'):
        with open('$LOCAL_SCREEN', 'rb') as f:
            img_b64 = base64.b64encode(f.read()).decode('utf-8')
    else: img_b64 = None
except: img_b64 = None

ui_xml = os.environ.get('UI_XML', 'Unavailable')[:15000]

system_prompt = '''You are a fast, efficient Android Agent. 
Analyze the screenshot and UI XML. 
Goal: ''' + task + '''
CRITICAL RULES:
1. Return JSON ONLY: {\"thought\": \"short reasoning\", \"action\": \"command\", \"args\": [arg1]}
2. DO NOT over-explain in thoughts.
3. Be precise with coordinates.
4. DO NOT repeat the same failed action. If tapping something does not work, try a slightly different coordinate or approach.
Valid actions: tap(x,y), swipe(x1,y1,x2,y2), type(text), key(code), open_app(package), home, back, wait(sec), done(message)'''

contents = [{'parts': [{'text': system_prompt}, {'text': 'UI Context: ' + ui_xml}]}]
if img_b64: contents[0]['parts'].append({'inline_data': {'mimeType': 'image/png', 'data': img_b64}})

print(json.dumps({
    'contents': contents,
    'generationConfig': {'responseMimeType': 'application/json', 'temperature': 0.1}
}))
" > "$PAYLOAD_FILE"

    # Fast API Call
    curl -s -X POST "https://generativelanguage.googleapis.com/v1beta/models/$MODEL:generateContent?key=$API_KEY" \
        -H "Content-Type: application/json" \
        -d @"$PAYLOAD_FILE" > "$RESPONSE_FILE"
        
    # Execute Action
    python3 -c "
import json, sys
try:
    with open('$RESPONSE_FILE') as f: data = json.load(f)
    if 'error' in data:
        print(f\"❌ API Error: {data['error'].get('message')}\")
        exit(1)
        
    text = data['candidates'][0]['content']['parts'][0]['text']
    cmd = json.loads(text)
    print(f\"💭 {cmd.get('thought', '')}\")
    print(f\"⚡ ACTION: {cmd.get('action')} {cmd.get('args')}\")
    
    with open('next_action.sh', 'w') as f:
        args = ' '.join([str(a) for a in cmd.get('args', [])])
        f.write(f\"do_action {cmd.get('action')} {args}\")
except Exception as e:
    print(f\"Error parsing: {e}\")
" > output.log

    cat output.log
    if [ -f next_action.sh ]; then
        source next_action.sh 2>/dev/null
        rm next_action.sh
    fi
    
    # Optimized wait: Only wait a tiny bit to let UI settle before next loop
    sleep 0.5
done
